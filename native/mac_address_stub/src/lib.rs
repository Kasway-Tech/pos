use std::fmt;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MacAddress([u8; 6]);

impl MacAddress {
    pub fn bytes(&self) -> [u8; 6] {
        self.0
    }
}

impl fmt::Display for MacAddress {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{:02x}:{:02x}:{:02x}:{:02x}:{:02x}:{:02x}",
            self.0[0], self.0[1], self.0[2], self.0[3], self.0[4], self.0[5]
        )
    }
}

#[derive(Debug)]
pub struct MacAddressError;

impl fmt::Display for MacAddressError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "mac_address not supported on this platform")
    }
}

impl std::error::Error for MacAddressError {}

pub fn get_mac_address() -> Result<Option<MacAddress>, MacAddressError> {
    Ok(None)
}
