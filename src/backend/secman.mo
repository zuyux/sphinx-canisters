import Text "mo:base/Text";

actor SecretManager {
    stable var openAIKey : Text = "open-ai-secret-key"; 
    
    stable var ownerPrivateKey : Text = "stacks-address-private-key"; 

    public query func getOpenAIKey() : async Text {
        return openAIKey;
    };

    public query func getOwnerPrivateKey() : async Text {
        return ownerPrivateKey;
    };
}
