import { ethers } from 'https://cdn.jsdelivr.net/npm/ethers@5.7.2/dist/ethers.esm.min.js';

let contract;
let signer;
let isMinting = false;

const CONTRACT_ADDRESS = "0xBB8480F36E688baA30833C49d092ecF6BebF1375";
const ABI_PATH = "./DragonMintZ.json";

function convertIpfsToHttp(ipfsUrl) {
    return ipfsUrl.replace("ipfs://", "https://ipfs.io/ipfs/");
}

async function displayCharacterDetails(metadataUri, characterId, skipAppend = false) {
    try {
        const metadataUrl = convertIpfsToHttp(metadataUri);
        const res = await fetch(metadataUrl);
        const metadata = await res.json();

        const card = document.createElement("div");
        card.className = "character-card";

        const name = document.createElement("h2");
        name.textContent = metadata.name;

        const img = document.createElement("img");
        img.src = convertIpfsToHttp(metadata.image);
        img.alt = metadata.name;

        const desc = document.createElement("p");
        desc.textContent = metadata.description;

        const attrContainer = document.createElement("div");
        attrContainer.className = "attributes";

        metadata.attributes.forEach(attr => {
            const attrBox = document.createElement("div");
            attrBox.className = "attribute";
            attrBox.innerHTML = `<strong>${attr.trait_type}:</strong> ${attr.value}`;
            attrContainer.appendChild(attrBox);
        });

        const userAddress = await signer.getAddress();
        const balance = await contract.balanceOf(userAddress, characterId);
        const balanceBox = document.createElement("div");
        balanceBox.className = "attribute";
        balanceBox.innerHTML = `<strong>Owned:</strong> ${balance.toString()}`;
        attrContainer.appendChild(balanceBox);

        card.appendChild(name);
        card.appendChild(img);
        card.appendChild(desc);
        card.appendChild(attrContainer);

        if (!skipAppend) {
            const displayArea = document.getElementById("characterDisplay");
            displayArea.innerHTML = "";
            displayArea.appendChild(card);
        }

        return card;
    } catch (err) {
        console.error("Failed to load character metadata:", err);
        document.getElementById("status").textContent = "Failed to load character details.";
    }
}

window.onload = async () => {
    const connectBtn = document.getElementById("connectWallet");
    const mintBtn = document.getElementById("mintBtn");

    connectBtn.onclick = async () => {
        if (!window.ethereum) {
            alert("MetaMask is required!");
            return;
        }

        try {
            console.log("Attempting to connect to wallet...");
            await window.ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: '0xaa36a7' }],
            });

            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const network = await provider.getNetwork();

            console.log("Network connected:", network.chainId);
            if (network.chainId !== 11155111) {
                alert("Please switch to the Sepolia network in MetaMask.");
                return;
            }

            await provider.send("eth_requestAccounts", []);
            signer = provider.getSigner();

            const res = await fetch(ABI_PATH);
            const abi = await res.json();
            contract = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

            console.log("Wallet connected:", await signer.getAddress());
            document.getElementById("status").textContent = `Wallet connected: ${await signer.getAddress()}`;
            mintBtn.disabled = false;

        } catch (err) {
            console.error("Error connecting wallet:", err);
            alert("Wallet connection failed or network switch rejected.");
        }
    };

    mintBtn.onclick = async () => {
        if (isMinting) {
            return;
        }

        isMinting = true;
        mintBtn.disabled = true;

        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const network = await provider.getNetwork();

            if (network.chainId !== 11155111) {
                try {
                    await window.ethereum.request({
                        method: 'wallet_switchEthereumChain',
                        params: [{ chainId: '0xaa36a7' }],
                    });

                    const newProvider = new ethers.providers.Web3Provider(window.ethereum);
                    signer = newProvider.getSigner();
                    const res = await fetch(ABI_PATH);
                    const abi = await res.json();
                    contract = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);
                } catch (switchErr) {
                    console.error("User rejected network switch or switch failed", switchErr);
                    alert("Please switch to the Sepolia network to mint.");
                    return;
                }
            }

            document.getElementById("status").textContent = "Minting...";
            const tx = await contract.mintRandomCharacter();
            const receipt = await tx.wait();

            const event = receipt.events?.find(e => e.event === "CharacterMinted");
            if (!event) throw new Error("CharacterMinted event not found");

            const [user, characterId, uri] = event.args;

            document.getElementById("status").textContent = "Minted successfully!";
            await displayCharacterDetails(uri, characterId);

            const hasAll = await contract.hasAllDragonBalls();
            if (hasAll) {
                document.getElementById("status").textContent += " All Dragon Balls collected! Summoning Shenron...";

                try {
                    await contract.callStatic.unleashShenron();
                    console.log("✅ Simulation passed. Proceeding to send unleashShenron transaction.");

                    const shenronTx = await contract.unleashShenron();
                    const shenronReceipt = await shenronTx.wait();

                    const shenronEvent = shenronReceipt.events?.find(e => e.event === "CharacterMinted");

                    if (shenronEvent) {
                        const [_, shenronId, shenronUri] = shenronEvent.args;

                        const shenronContainer = document.createElement("div");
                        shenronContainer.className = "shenron-glow";

                        const shenronCard = await displayCharacterDetails(shenronUri, shenronId, true);
                        shenronContainer.appendChild(shenronCard);
                        document.getElementById("characterDisplay").appendChild(shenronContainer);

                        document.getElementById("status").textContent += " Shenron has appeared!";
                    }
                } catch (simErr) {
                    console.error("❌ Simulation or unleashShenron failed:", simErr);
                    document.getElementById("status").textContent += " Failed to summon Shenron.";
                }
            }
        } catch (err) {
            console.error("Minting failed:", err);

            if (err.error) {
                console.error("Inner error:", err.error);
            }
            if (err.transaction) {
                console.error("Transaction object:", err.transaction);
            }
            if (err.receipt) {
                console.error("Transaction receipt:", err.receipt);
            }
            if (err.code) {
                console.error("Error code:", err.code);
            }

            document.getElementById("status").textContent = "Mint failed!";
        } finally {
            isMinting = false;
            mintBtn.disabled = false;
        }
    };
};
