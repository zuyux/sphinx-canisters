import Timer "mo:base/Timer";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import HttpTypes "mo:http-types";
import Date "mo:base/Date";

actor gen {

    // Reference to the Secret Manager (sec.mo)
    public let secretManager = actor("sec") : actor {
        getOpenAIKey: () -> async Text;
        getPinataApiKey: () -> async Text;
        getPinataSecretApiKey: () -> async Text;
        getOwnerPrivateKey: () -> async Text;
    };

    // Reference to ICP Management Canister for HTTP requests
    private let icManagementCanister = actor("aaaaa-aa") : actor {
        http_request: (HttpTypes.Request) -> async HttpTypes.Response;
    };

    // Generate daily question ID based on the current date
    func generateQuestionId() : Text {
        let date = Date.now();
        return Date.toText(date).substring(0, 10).replaceAll("-", "");  // e.g., "20241030" for 2024-10-30
    }

    // Function to create a new question
    async func createDailyQuestion() : async ?Text {
        let openAIKey = await secretManager.getOpenAIKey();
        let pinataApiKey = await secretManager.getPinataApiKey();
        let pinataSecretKey = await secretManager.getPinataSecretApiKey();
        let questionId = generateQuestionId();

        // Generate question content via OpenAI
        let openAIResponse = await http_post("https://api.openai.com/v1/completions", [
            ("Content-Type", "application/json"),
            ("Authorization", "Bearer " # openAIKey)
        ], ?Blob.fromText("{\"prompt\":\"Generate a question for today.\",\"max_tokens\":100}"));

        if (openAIResponse.status_code != 200) {
            Debug.print("OpenAI request failed: " # Int.toText(openAIResponse.status_code));
            return null;
        }

        let questionContent = Text.decodeUtf8(openAIResponse.body);

        // Store question metadata in IPFS via Pinata
        let pinataResponse = await http_post("https://api.pinata.cloud/pinning/pinJSONToIPFS", [
            ("Content-Type", "application/json"),
            ("pinata_api_key", pinataApiKey),
            ("pinata_secret_api_key", pinataSecretKey)
        ], ?Blob.fromText("{\"questionId\":\"" # questionId # "\",\"content\":" # questionContent # "}"));

        if (pinataResponse.status_code == 200) {
            let ipfsCID = Text.decodeUtf8(pinataResponse.body);  // Extract CID
            return ipfsCID;
        } else {
            Debug.print("Pinata request failed: " # Int.toText(pinataResponse.status_code));
            return null;
        }
    }

    // Function to close the question after 24 hours if not closed
    async func closeExpiredQuestion() : async () {
        let isClosed = await isQuestionClosed();
        if (!isClosed) {
            let _ = await closeQuestionOnStacks();
            await analyzeResponsesAndRewardWinner();
        }
    }

    // Timer for daily question creation at midnight UTC
    Timer.recurring(async {
        if (Date.now().getHours() == 0) {  // Check if it’s 0:00 UTC
            await createDailyQuestion();
        }
    }, 86400); // Run once every 24 hours

    // Timer for checking question expiration every 6 hours
    Timer.recurring(async {
        await closeExpiredQuestion();
    }, 21600); // Run every 6 hours

    // Check if the current question is closed
    async func isQuestionClosed() : async Bool {
        // Implement logic to call Stacks API and check question status
        ...
    }

    // Close the question on Stacks blockchain
    async func closeQuestionOnStacks() : async Bool {
        let ownerKey = await secretManager.getOwnerPrivateKey();
        // Implement logic to call Stacks API to close question
        ...
    }

    // Fetch responses, analyze them using OpenAI, and transfer funds to the winner
    async func analyzeResponsesAndRewardWinner() : async () {
        let responses = await getResponses();

        if (Array.size(responses) > 0) {
            let responseCIDs = Array.map(responses, func (r) { r.1 });
            let prompt = "Evaluate the following responses to select the best one:\n\n" # Text.concat(responseCIDs, "\n");

            let openAIKey = await secretManager.getOpenAIKey();
            let openAIResponse = await http_post("https://api.openai.com/v1/completions", [
                ("Content-Type", "application/json"),
                ("Authorization", "Bearer " # openAIKey)
            ], ?Blob.fromText("{\"prompt\":\"" # prompt # "\",\"max_tokens\":50}"));

            if (openAIResponse.status_code == 200) {
                let selectedAddress = Text.decodeUtf8(openAIResponse.body); // Extract the address of the winner
                if (Text.contains(selectedAddress, "SP") or Text.contains(selectedAddress, "ST")) {
                    await transferFundsToWinner(Principal.fromText(selectedAddress));
                } else {
                    Debug.print("No valid winner selected, funds will remain in the contract.");
                }
            } else {
                Debug.print("OpenAI failed to select a winner.");
            }
        } else {
            Debug.print("No responses found for analysis.");
        }
    }

    // Transfer funds to the winner’s address
    async func transferFundsToWinner(winner: Principal) : async Bool {
        let ownerKey = await secretManager.getOwnerPrivateKey();
        // Implement fund transfer logic on Stacks API
        ...
    }

    // Fetch responses from Stacks contract
    async func getResponses() : async [(Principal, Text)] {
        // Implement HTTP GET to retrieve response list from Stacks contract
        ...
    }
}
