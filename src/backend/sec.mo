import Text "mo:base/Text";
import Principal "mo:base/Principal";

actor SecretManager {
    // Define variables to store keys
    stable var openAIKey : Text = "open-ai-secret-key";
    stable var pinataApiKey : Text = "pinata-api-key";
    stable var pinataSecretApiKey : Text = "pinata-secret-api-key";
    stable var ownerPrivateKey : Text = "stacks-address-private-key";

    // Define the principal that is allowed to update keys (could be the principal of gen.mo)
    let authorizedCaller : Principal = Principal.fromText("your-authorized-principal-id");

    // Getter functions for each key (with access control)
    public query func getOpenAIKey() : async ?Text {
        if (caller == authorizedCaller) {
            return ?openAIKey;
        } else {
            return null;  // Unauthorized access returns null
        }
    };

    public query func getPinataApiKey() : async ?Text {
        if (caller == authorizedCaller) {
            return ?pinataApiKey;
        } else {
            return null;
        }
    };

    public query func getPinataSecretApiKey() : async ?Text {
        if (caller == authorizedCaller) {
            return ?pinataSecretApiKey;
        } else {
            return null;
        }
    };

    public query func getOwnerPrivateKey() : async ?Text {
        if (caller == authorizedCaller) {
            return ?ownerPrivateKey;
        } else {
            return null;
        }
    };

    // Setter functions to allow updating keys if needed
    public func updateOpenAIKey(newKey : Text) : async Bool {
        if (caller == authorizedCaller) {
            openAIKey := newKey;
            return true;
        } else {
            return false;  // Unauthorized update attempt
        }
    };

    public func updatePinataApiKey(newKey : Text) : async Bool {
        if (caller == authorizedCaller) {
            pinataApiKey := newKey;
            return true;
        } else {
            return false;
        }
    };

    public func updatePinataSecretApiKey(newKey : Text) : async Bool {
        if (caller == authorizedCaller) {
            pinataSecretApiKey := newKey;
            return true;
        } else {
            return false;
        }
    };

    public func updateOwnerPrivateKey(newKey : Text) : async Bool {
        if (caller == authorizedCaller) {
            ownerPrivateKey := newKey;
            return true;
        } else {
            return false;
        }
    };
}
