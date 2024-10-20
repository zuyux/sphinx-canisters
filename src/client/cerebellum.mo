import Timer "mo:base/Timer";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import HttpTypes "mo:http-types";

actor cerebellum {

    // Reference to the Secret Manager
    public let secretManager = actor("secman") : actor {
        getOpenAIKey: () -> async Text;
        getOwnerPrivateKey: () -> async Text; 
    };

    // Reference to the ICP Management Canister
    private let icManagementCanister = actor("aaaaa-aa") : actor {
        rawHTTPSOutcall: (HttpTypes.Request) -> async HttpTypes.Response;
    };

    // Utility function to perform an HTTP GET request
    async func http_get(url: Text, headers: [(Text, Text)] = []) : async HttpTypes.Response {
        // Set headers to default value if not provided
        let effectiveHeaders : [(Text, Text)] = if (Array.size(headers) == 0) {
            [("Content-Type", "application/json")]
        } else {
            headers;
        };

        let request: HttpTypes.Request = {
            url = url;
            method = #get;
            headers = effectiveHeaders;
            body = null;
        };

        return await icManagementCanister.rawHTTPSOutcall(request);
    };


    // Utility function to perform an HTTP POST request using ICP Management Canister
    async func http_post(url: Text, headers: [(Text, Text)], body: ?Blob) : async HttpTypes.Response {
        let request: HttpTypes.Request = {
            url = url;
            method = #post;
            headers = headers;
            body = body;
        };
        
        return await icManagementCanister.rawHTTPSOutcall(request);
    };

    // Function to check if question is closed using the Stacks API
    async func isQuestionClosed() : async Bool {
        let url = "https://stacks-node-api.mainnet.stacks.co/v2/contracts/call-read/ST28B2GFEWHR2MXA6P0XNW2GVV9K30HYSC3D9Q0SR/get-question-details";
        let response = await http_get(url);

        if (response.status_code == 200) {
            let jsonResponse = Text.decodeUtf8(response.body);
            switch (jsonResponse) {
                case (?text) {
                    // Assuming the JSON response has a field `status` with value "closed" or "open"
                    if (Text.contains(text, "\"status\":\"closed\"")) {
                        return true;
                    } else {
                        return false;
                    };
                };
                case null {
                    return false;
                };
            };
        } else {
            Debug.print("Failed to query Stacks API: " # Int.toText(response.status_code));
            return false;
        };
    };

    // Function to close a question using the Stacks API
    async func closeQuestionOnStacks() : async Bool {
        let url = "https://stacks-node-api.mainnet.stacks.co/v2/contracts/call-write/ST28B2GFEWHR2MXA6P0XNW2GVV9K30HYSC3D9Q0SR/close-question";
        let ownerKey = await secretManager.getOwnerPrivateKey();
        let response = await http_post(url, [
            ("Content-Type", "application/json"),
            ("Authorization", "Bearer " # ownerKey)
        ], null);

        if (response.status_code == 200) {
            return true;
        } else {
            Debug.print("Failed to close the question on Stacks: " # Int.toText(response.status_code));
            return false;
        };
    };

    // Function to transfer funds to winner using the Stacks API
    async func transferFundsToWinner(winner: Principal) : async Bool {
        let url = "https://stacks-node-api.mainnet.stacks.co/v2/contracts/call-write/ST28B2GFEWHR2MXA6P0XNW2GVV9K30HYSC3D9Q0SR/transfer-funds";
        let ownerKey = await secretManager.getOwnerPrivateKey();
        let bodyText = "{" #
            "\"recipient\": \"" # Principal.toText(winner) # "\"," #
            "\"amount\": 100" #  // Example amount
            "}";
        let response = await http_post(url, [
            ("Content-Type", "application/json"),
            ("Authorization", "Bearer " # ownerKey)
        ], ?Text.encodeUtf8(bodyText));

        if (response.status_code == 200) {
            return true;
        } else {
            Debug.print("Failed to transfer funds on Stacks: " # Int.toText(response.status_code));
            return false;
        };
    };

    // Function to check if question is timed out and close it
    func checkAndCloseQuestion() : async () {
        let isClosed = await isQuestionClosed();
        if (not isClosed) {
            let questionClosed = await closeQuestionOnStacks();
            if (questionClosed) {
                // Assuming `getResponses` is a function that retrieves responses
                let responses = await getResponses();
                if (Array.size(responses) > 0) {
                    let (winner, _) = responses[0];  // Taking the first response as winner
                    let _ = await transferFundsToWinner(winner);
                } else {
                    Debug.print("No responses found. No winner declared.");
                };
            }
        }
    };

    // Timer setup: Run every hour
    let ONE_HOUR = 3600; // Seconds
    Timer.recurring(async { await checkAndCloseQuestion(); }, ONE_HOUR);

    // Function to get responses from the Stacks API
    async func getResponses() : async [(Principal, Text)] {
        let url = "https://stacks-node-api.mainnet.stacks.co/v2/contracts/call-read/ST28B2GFEWHR2MXA6P0XNW2GVV9K30HYSC3D9Q0SR/get-responses";
        
        // Make an HTTP GET request to retrieve responses
        let response = await http_get(url, []);

        if (response.status_code == 200) {
            let jsonResponse = Text.decodeUtf8(response.body);
            switch (jsonResponse) {
                case (?text) {
                    // Assume JSON format: [{"user": "<user_principal>", "response": "<response_text>"}, ...]
                    try {
                        let responseList = JSON.parse(text);
                        var parsedResponses : [(Principal, Text)] = [];
                        for (response in responseList) {
                            
                            let userPrincipal = Principal.fromText(response["user"]);
                            let responseText = response["response"];
                            
                            switch (userPrincipal) {
                                case (?principal) {
                                    parsedResponses := Array.append(parsedResponses, [(principal, responseText)]);
                                };
                                case null {
                                    Debug.print("Invalid principal found in response JSON.");
                                };
                            };
                        };
                        return parsedResponses;
                    } catch (e) {
                        Debug.print("Failed to parse responses: " # e.message);
                        return [];
                    };
                };
                case null {
                    Debug.print("Failed to decode response body.");
                    return [];
                };
            };
        } else {
            Debug.print("Failed to query Stacks API for responses: " # Int.toText(response.status_code));
            return [];
        };
    };


}
