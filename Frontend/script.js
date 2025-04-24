import { ethers } from 'https://cdn.jsdelivr.net/npm/ethers@5.7.2/dist/ethers.esm.min.js';

let contract;
let signer;

const CONTRACT_ADDRESS = "0x6F12aed73C96b8Ff5b53278ec7Ad9e8F844fe4ab"; // Replace with contract address
const ABI_PATH = "./DragonMintZ.json";

function convertIpfsToHttp(ipfsUrl) {
    return ipfsUrl.replace("ipfs://", "https://ipfs.io/ipfs/");
}

async function displayCharacterDetails(metadataUri, characterId, skipAppend = false) {
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

    // Fetch and display balance
    const balance = await contract.getBalanceOfToken(characterId);
    const balanceBox = document.createElement("div");
    balanceBox.className = "attribute";
    balanceBox.innerHTML = `<strong>Owned:</strong> ${balance}`;
    attrContainer.appendChild(balanceBox);

    card.appendChild(name);
    card.appendChild(img);
    card.appendChild(desc);
    card.appendChild(attrContainer);

    if (!skipAppend) {
        const displayArea = document.getElementById("characterDisplay");
        displayArea.innerHTML = ""; // Clear previous
        displayArea.appendChild(card);
    }

    return card; // Return the card element
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
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            await provider.send("eth_requestAccounts", []);
            signer = await provider.getSigner();
            const res = await fetch(ABI_PATH);
            const abi = await res.json();

            contract = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

            document.getElementById("status").textContent = `Wallet connected: ${await signer.getAddress()}`;
            mintBtn.disabled = false;

        } catch (err) {
            console.error(err);
            alert("Wallet connection failed");
        }
    };

    mintBtn.onclick = async () => {
        try {
            document.getElementById("status").textContent = "Minting...";
            const tx = await contract.mintRandomCharacter();
            const receipt = await tx.wait();

            const event = receipt.events?.find(e => e.event === "CharacterMinted");
            if (!event) throw new Error("CharacterMinted event not found");

            const [user, characterId, uri] = event.args;

            document.getElementById("status").textContent = `Minted successfully!`;
            await displayCharacterDetails(uri, characterId);

            // Check for all Dragon Balls
            const hasAll = await contract.hasAllDragonBalls();
            if (hasAll) {
                document.getElementById("status").textContent += " All Dragon Balls collected! Summoning Shenron...";

                const shenronTx = await contract.unleashShenron();
                const shenronReceipt = await shenronTx.wait();
                const shenronEvent = shenronReceipt.events?.find(e => e.event === "CharacterMinted");
                if (shenronEvent) {
                    const [_, shenronId, shenronUri] = shenronEvent.args;

                    const shenronContainer = document.createElement("div");
                    shenronContainer.className = "shenron-glow";

                    const shenronCard = await displayCharacterDetails(shenronUri, shenronId, true); // don't auto-append

                    shenronContainer.appendChild(shenronCard);
                    document.getElementById("characterDisplay").appendChild(shenronContainer);

                    document.getElementById("status").textContent += " Shenron has appeared!";
                }


            }

        } catch (err) {
            console.error(err);
            document.getElementById("status").textContent = "Mint failed!";
        }
    };


};
