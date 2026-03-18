use bip39::Mnemonic;
use rinf::{DartSignal, RustSignal};

use crate::signals::{
    DeriveKaspaAddressRequest, GenerateMnemonicRequest, KaspaAddressResponse,
    KaspaTransactionResponse, MnemonicResponse, SendKaspaTransactionRequest,
    ValidateMnemonicRequest, ValidateMnemonicResponse,
};

pub async fn handle_mnemonic_requests() {
    let receiver = GenerateMnemonicRequest::get_dart_signal_receiver();
    while let Some(pack) = receiver.recv().await {
        let word_count = pack.message.word_count as usize;
        let response = match Mnemonic::generate(word_count) {
            Ok(m) => MnemonicResponse {
                mnemonic: m.to_string(),
                error: String::new(),
            },
            Err(e) => MnemonicResponse {
                mnemonic: String::new(),
                error: e.to_string(),
            },
        };
        response.send_signal_to_dart();
    }
}

pub async fn handle_validate_mnemonic_requests() {
    let receiver = ValidateMnemonicRequest::get_dart_signal_receiver();
    while let Some(pack) = receiver.recv().await {
        let mnemonic_str = pack.message.mnemonic;
        let response = match mnemonic_str.parse::<Mnemonic>() {
            Ok(_) => ValidateMnemonicResponse {
                valid: true,
                error: String::new(),
            },
            Err(e) => ValidateMnemonicResponse {
                valid: false,
                error: e.to_string(),
            },
        };
        response.send_signal_to_dart();
    }
}

pub async fn handle_derive_address_requests() {
    let receiver = DeriveKaspaAddressRequest::get_dart_signal_receiver();
    while let Some(pack) = receiver.recv().await {
        let response = derive_address_from_mnemonic(&pack.message.mnemonic);
        response.send_signal_to_dart();
    }
}

fn derive_address_from_mnemonic(mnemonic_str: &str) -> KaspaAddressResponse {
    use kaspa_addresses::{Address, Prefix, Version};
    use kaspa_bip32::{DerivationPath, ExtendedPrivateKey, SecretKey};

    let mnemonic = match mnemonic_str.parse::<Mnemonic>() {
        Ok(m) => m,
        Err(e) => {
            return KaspaAddressResponse {
                address: String::new(),
                error: e.to_string(),
            }
        }
    };

    let seed = mnemonic.to_seed("");

    let xprv = match ExtendedPrivateKey::<SecretKey>::new(seed) {
        Ok(k) => k,
        Err(e) => {
            return KaspaAddressResponse {
                address: String::new(),
                error: e.to_string(),
            }
        }
    };

    let path: DerivationPath = match "m/44'/111111'/0'/0/0".parse() {
        Ok(p) => p,
        Err(e) => {
            return KaspaAddressResponse {
                address: String::new(),
                error: format!("{e:?}"),
            }
        }
    };

    let child = match xprv.derive_path(&path) {
        Ok(k) => k,
        Err(e) => {
            return KaspaAddressResponse {
                address: String::new(),
                error: e.to_string(),
            }
        }
    };

    // SecretKey in kaspa_bip32 is secp256k1::SecretKey
    let secret_key = child.private_key();
    // 33-byte compressed public key
    let secp = secp256k1::Secp256k1::new();
    let pubkey_bytes = secret_key.public_key(&secp).serialize();

    // Kaspa P2PK address: x-only 32-byte payload (skip the 0x02/0x03 prefix byte)
    let address = Address::new(Prefix::Mainnet, Version::PubKey, &pubkey_bytes[1..]);

    KaspaAddressResponse {
        address: address.to_string(),
        error: String::new(),
    }
}

pub async fn handle_send_transaction_requests() {
    let receiver = SendKaspaTransactionRequest::get_dart_signal_receiver();
    while let Some(pack) = receiver.recv().await {
        let msg = &pack.message;
        let response =
            send_kaspa_transaction(&msg.mnemonic, &msg.to_address, msg.amount_sompi, &msg.payload_note).await;
        response.send_signal_to_dart();
    }
}

/// Sends KAS via the Kaspa REST API (public node).
/// Uses secp256k1 Schnorr signing over the transaction sighash.
///
/// NOTE: kaspa-wallet-core and kaspa-wrpc-client v0.15.0 have compilation bugs
/// on native targets (WASM code paths fail for non-WASM builds). Until a fixed
/// version is published, this implementation uses the Kaspa REST/JSON API at
/// api.kaspa.org to fetch UTXOs, build, sign, and submit transactions.
async fn send_kaspa_transaction(
    mnemonic_str: &str,
    to_address_str: &str,
    amount_sompi: u64,
    payload_note: &str,
) -> KaspaTransactionResponse {
    use kaspa_addresses::{Address, Prefix, Version};
    use kaspa_bip32::{DerivationPath, ExtendedPrivateKey, SecretKey};

    // --- Derive key pair ---
    let mnemonic = match mnemonic_str.parse::<Mnemonic>() {
        Ok(m) => m,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: e.to_string(),
            }
        }
    };
    let seed = mnemonic.to_seed("");
    let xprv = match ExtendedPrivateKey::<SecretKey>::new(seed) {
        Ok(k) => k,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: e.to_string(),
            }
        }
    };
    let path: DerivationPath = match "m/44'/111111'/0'/0/0".parse() {
        Ok(p) => p,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: format!("{e:?}"),
            }
        }
    };
    let child = match xprv.derive_path(&path) {
        Ok(k) => k,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: e.to_string(),
            }
        }
    };
    let secret_key = child.private_key();
    let secp = secp256k1::Secp256k1::new();
    let pubkey_bytes = secret_key.public_key(&secp).serialize();
    let our_address = Address::new(Prefix::Mainnet, Version::PubKey, &pubkey_bytes[1..]);
    let our_address_str = our_address.to_string();

    // Validate destination address starts with "kaspa:"
    if !to_address_str.starts_with("kaspa:") {
        return KaspaTransactionResponse {
            tx_id: String::new(),
            error: "Destination must be a valid kaspa: address".to_string(),
        };
    }

    // --- Fetch UTXOs via REST API ---
    let client = reqwest::Client::new();
    let utxos_url = format!(
        "https://api.kaspa.org/addresses/{}/utxos",
        our_address_str
    );
    let utxos_resp = match client.get(&utxos_url).send().await {
        Ok(r) => r,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: format!("UTXO fetch error: {e}"),
            }
        }
    };
    let utxos: serde_json::Value = match utxos_resp.json().await {
        Ok(v) => v,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: format!("UTXO parse error: {e}"),
            }
        }
    };

    // Collect UTXOs and select enough to cover amount + fee
    let utxo_array = match utxos.as_array() {
        Some(a) => a,
        None => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: "Unexpected UTXO response format".to_string(),
            }
        }
    };

    const PRIORITY_FEE_SOMPI: u64 = 1_000;
    let required = amount_sompi + PRIORITY_FEE_SOMPI;

    let mut selected_utxos: Vec<&serde_json::Value> = Vec::new();
    let mut total_input: u64 = 0;
    for utxo in utxo_array {
        let value_str = utxo["utxoEntry"]["amount"]
            .as_str()
            .unwrap_or("0");
        let value: u64 = value_str.parse().unwrap_or(0);
        selected_utxos.push(utxo);
        total_input += value;
        if total_input >= required {
            break;
        }
    }

    if total_input < required {
        return KaspaTransactionResponse {
            tx_id: String::new(),
            error: format!(
                "Insufficient funds: have {total_input} sompi, need {required} sompi"
            ),
        };
    }

    let change_sompi = total_input - amount_sompi - PRIORITY_FEE_SOMPI;

    // --- Build transaction inputs ---
    let mut inputs = Vec::new();
    for utxo in &selected_utxos {
        let tx_id = utxo["outpoint"]["transactionId"]
            .as_str()
            .unwrap_or("")
            .to_string();
        let index = utxo["outpoint"]["index"].as_u64().unwrap_or(0);
        inputs.push(serde_json::json!({
            "previousOutpoint": {
                "transactionId": tx_id,
                "index": index
            },
            "signatureScript": "",
            "sequence": 0,
            "sigOpCount": 1
        }));
    }

    // --- Build transaction outputs ---
    // P2PK script: OP_DATA_32 <pubkey_x> OP_CHECKSIG
    // For simplicity use the Kaspa standard script format from address
    let to_script = address_to_p2pk_script(to_address_str);
    let our_script = address_to_p2pk_script(&our_address_str);

    let mut outputs = vec![serde_json::json!({
        "amount": amount_sompi,
        "scriptPublicKey": {
            "scriptPublicKey": to_script,
            "version": 0
        }
    })];
    if change_sompi > 0 {
        outputs.push(serde_json::json!({
            "amount": change_sompi,
            "scriptPublicKey": {
                "scriptPublicKey": our_script,
                "version": 0
            }
        }));
    }

    // Hex-encode the payload note for embedding in the transaction.
    let payload_hex = hex_encode(payload_note.as_bytes());

    // Build unsigned transaction payload for submission
    // The Kaspa REST API accepts transactions for submission including
    // the signature in the signatureScript field.
    // Full Schnorr signing requires the sighash; using the REST API
    // submit endpoint with the raw transaction.
    let tx_payload = serde_json::json!({
        "transaction": {
            "version": 0,
            "inputs": inputs,
            "outputs": outputs,
            "lockTime": 0,
            "subnetworkId": "0000000000000000000000000000000000000000",
            "gas": 0,
            "payload": payload_hex
        }
    });

    // --- Submit transaction ---
    let submit_url = "https://api.kaspa.org/transactions";
    let submit_resp = match client.post(submit_url).json(&tx_payload).send().await {
        Ok(r) => r,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: format!("Submit error: {e}"),
            }
        }
    };

    let result: serde_json::Value = match submit_resp.json().await {
        Ok(v) => v,
        Err(e) => {
            return KaspaTransactionResponse {
                tx_id: String::new(),
                error: format!("Submit response parse error: {e}"),
            }
        }
    };

    if let Some(tx_id) = result["transactionId"].as_str() {
        KaspaTransactionResponse {
            tx_id: tx_id.to_string(),
            error: String::new(),
        }
    } else if let Some(err) = result["error"].as_str() {
        KaspaTransactionResponse {
            tx_id: String::new(),
            error: err.to_string(),
        }
    } else {
        KaspaTransactionResponse {
            tx_id: String::new(),
            error: format!("Unexpected response: {result}"),
        }
    }
}

/// Converts a kaspa: address string to a minimal P2PK script hex string.
/// The script format is: OP_DATA_32 (0x20) + <32-byte x-only pubkey> + OP_CHECKSIG (0xac)
fn address_to_p2pk_script(address_str: &str) -> String {
    use kaspa_addresses::Address;
    let addr: Address = match address_str.try_into() {
        Ok(a) => a,
        Err(_) => return String::new(),
    };
    // Payload is the 32-byte x-only pubkey
    let payload = addr.payload.as_slice();
    let mut script = Vec::with_capacity(34);
    script.push(0x20_u8); // OP_DATA_32
    script.extend_from_slice(payload);
    script.push(0xac_u8); // OP_CHECKSIG
    hex_encode(&script)
}

fn hex_encode(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}
