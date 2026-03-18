use rinf::{DartSignal, RustSignal, SignalPiece};
use serde::{Deserialize, Serialize};

/// To send data from Dart to Rust, use `DartSignal`.
#[derive(Deserialize, DartSignal)]
pub struct SmallText {
    pub text: String,
}

/// Dart → Rust: request a new BIP39 mnemonic.
#[derive(Deserialize, DartSignal)]
pub struct GenerateMnemonicRequest {
    pub word_count: u32,
}

/// Rust → Dart: generated mnemonic phrase.
#[derive(Serialize, RustSignal)]
pub struct MnemonicResponse {
    pub mnemonic: String,
    pub error: String,
}

/// Dart → Rust: validate an existing BIP39 mnemonic.
#[derive(Deserialize, DartSignal)]
pub struct ValidateMnemonicRequest {
    pub mnemonic: String,
}

/// Rust → Dart: result of mnemonic validation.
#[derive(Serialize, RustSignal)]
pub struct ValidateMnemonicResponse {
    pub valid: bool,
    pub error: String,
}

/// To send data from Rust to Dart, use `RustSignal`.
#[derive(Serialize, RustSignal)]
pub struct SmallNumber {
    pub number: i32,
}

/// A signal can be nested inside another signal.
#[derive(Serialize, RustSignal)]
pub struct BigBool {
    pub member: bool,
    pub nested: SmallBool,
}

/// To nest a signal inside other signal, use `SignalPiece`.
#[derive(Serialize, SignalPiece)]
pub struct SmallBool(pub bool);
