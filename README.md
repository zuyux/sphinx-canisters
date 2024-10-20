# sphinx-canisters

📦 Canisters for interacting with Sphinx 🔗 Stacks contracts

## 📝 Overview

The **sphinx-canisters** repository contains 🌐 Internet Computer (ICP) canisters that interact with **Stacks blockchain contracts** for managing 🌍 decentralized question-and-response sessions. The canisters automate operations like ✅ checking if a question has timed out, ⛔ closing questions, 🤖 calling OpenAI for evaluation, and 💸 transferring rewards to participants.

The main components of the repository include:
- `requestor.mo`: Handles interactions with the Stacks contracts, calls 🤖 OpenAI API to evaluate responses, and manages the flow of the Sphinx process.
- `secman.mo`: A 🔒 secret manager canister for securely storing API 🔑 keys and private 🔑 keys.

## ⚙️ Functionality

The canisters provide functionality for:

1. **⏰ Timer-based Automation**
   - A recurring ⏱️ timer is set to run every ⏳ hour using the `Timer` module from the 🛠️ Motoko base library. This timer triggers the main operation of checking whether a question is timed out and, if necessary, closes it and evaluates responses.

2. **🔗 Stacks API Integration**
   - The `requestor.mo` canister interacts with the **Stacks blockchain** using 🌐 HTTP outcalls. It checks if a question contract is open or closed, closes it, and initiates 💰 fund transfers.
   - For interaction, HTTPS 📡 GET and POST requests are used to call the Stacks contracts.

3. **🤖 OpenAI Integration**
   - The canister integrates with the **OpenAI API** to generate insights or rank user responses for specific questions. The chosen response is used to decide the 🏆 winner in the decentralized Sphinx process.

4. **🔒 Secret Management**
   - The `secman.mo` canister is responsible for securely managing sensitive information such as the **OpenAI API key** and **Stacks contract owner’s private key**.

## 🚀 How it Works

1. **⏰ Recurring Timer**
   - A timer runs every ⏳ hour to check the status of questions. If a question is found to be closed (timed out), it proceeds to initiate closure operations.

2. **🔍 Question Status Check**
   - The canister sends a 📡 GET request to the **Stacks blockchain API** to check if the current question is open or closed. If it is open, the canister continues monitoring until a timeout occurs.

3. **⛔ Close Question and Evaluate Responses**
   - Once a question is deemed timed out, the canister sends a 📡 POST request to close it on the **Stacks blockchain**.
   - After the question is closed, it retrieves all user responses stored in a contract. If there are responses available, the canister builds a prompt and calls the **OpenAI API** to evaluate and determine the best response.

4. **💸 Fund Transfer to Winner**
   - The 🏆 winner of the question (based on 🤖 OpenAI evaluation) receives a reward. The canister initiates a 📡 POST request to the Stacks contract to transfer 💰 funds to the winning participant's address.
   - If no responses are available in the contract, no winner is declared, and $PHI tokens on the contract's pool are burned.

## 🛠️ Setup Instructions

1. **📥 Clone the Repository**
   ```sh
   git clone https://github.com/zuyux/sphinx-canisters.git
   cd sphinx-canisters
   ```

2. **🔧 Install Dependencies**
   Ensure that you have **DFX** (the 🌐 Internet Computer SDK) installed. You also need the **Motoko compiler**.

3. **📝 Update Configuration**
   Update the **dfx.json** file with the appropriate 🆔 Principal IDs for the Stacks contracts, 🤖 OpenAI API keys, and other necessary configurations.

4. **🚀 Deploy Canisters**
   Use the following commands to deploy the canisters:
   ```sh
   dfx start --background
   dfx deploy
   ```

## ⚙️ Configuration Details

- **🔗 Stacks API URLs**: The canister uses the Stacks API to interact with contracts. Make sure to use the correct endpoints for reading contract data (`GET`) and writing to contracts (`POST`).
- **🔒 Authorization**: To interact with the Stacks blockchain, the owner's private key is used. It is stored securely in the `secman.mo` canister.

## 📂 Key Files

- **`requestor.mo`**: Manages the core logic for interacting with the Sphinx contracts, 🤖 OpenAI API calls, and flow management.
- **`secman.mo`**: A 🔒 secret manager for storing sensitive credentials like API keys.

## 📝 Example Workflow

1. **⏱️ Timer triggers** every hour to check the question status.
2. **🔍 Status check**: Sends a 📡 GET request to determine if the question is timed out.
3. If timed out, **⛔ closes the question** using a 📡 POST request.
4. Retrieves responses and **evaluates with 🤖 OpenAI**.
5. **💸 Transfers funds** to the selected winning address via the Stacks contract.

## 📄 License
This repository is licensed under the 📝 MIT License.

