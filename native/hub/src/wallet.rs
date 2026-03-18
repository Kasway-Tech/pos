use bip39::Mnemonic;
use rinf::{DartSignal, RustSignal};

use crate::signals::{
    GenerateMnemonicRequest, MnemonicResponse, ValidateMnemonicRequest, ValidateMnemonicResponse,
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
