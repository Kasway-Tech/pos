use std::env;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("cargo:rerun-if-changed=src/keccakf1600_x86-64.s");
    println!("cargo:rerun-if-changed=src/keccakf1600_x86-64-osx.s");

    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    let no_asm = env::var("CARGO_FEATURE_NO_ASM").is_ok();

    // Skip assembly entirely when no-asm feature is enabled, or on iOS (Mach-O
    // but not macOS — the Linux ELF .s file would fail to assemble there).
    if no_asm || target_os == "ios" {
        return Ok(());
    }

    if target_arch == "x86_64" && target_os != "windows" && target_os != "macos" {
        cc::Build::new().flag("-c").file("src/keccakf1600_x86-64.s").compile("libkeccak.a");
    }
    if target_arch == "x86_64" && (target_os == "macos" || target_os == "ios") {
        cc::Build::new().flag("-c").file("src/keccakf1600_x86-64-osx.s").compile("libkeccak.a");
    }
    Ok(())
}
