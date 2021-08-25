// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! This file implements length and character set limited string types needed
//! for DijetsID as defined by DIP-10: https://github.com/dijets/dip/blob/main/dips/dip-10.md

use serde::{de, Serialize};
use std::{
    fmt::{Display, Formatter},
    str::FromStr,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DijetsId {
    // A reusable identifier that represents either the source or destination
    // end-user of a payment transaction. It is unique to per user at VASP level
    user_identifier: DijetsIdUserIdentifier,
    // A unique string that is mapped to a VASP
    vasp_domain_identifier: DijetsIdVaspDomainIdentifier,
}

impl DijetsId {
    pub fn new(
        user_identifier: DijetsIdUserIdentifier,
        vasp_domain_identifier: DijetsIdVaspDomainIdentifier,
    ) -> Self {
        Self {
            user_identifier,
            vasp_domain_identifier,
        }
    }

    fn new_from_raw(
        user_identifier: &str,
        vasp_domain_identifier: &str,
    ) -> Result<Self, DijetsIdParseError> {
        Ok(DijetsId::new(
            DijetsIdUserIdentifier::new(user_identifier)?,
            DijetsIdVaspDomainIdentifier::new(vasp_domain_identifier)?,
        ))
    }

    pub fn user_identifier(&self) -> &DijetsIdUserIdentifier {
        &self.user_identifier
    }

    pub fn vasp_domain_identifier(&self) -> &DijetsIdVaspDomainIdentifier {
        &self.vasp_domain_identifier
    }
}

impl Display for DijetsId {
    fn fmt(&self, f: &mut Formatter) -> std::fmt::Result {
        write!(
            f,
            "{}@{}",
            self.user_identifier.as_str(),
            self.vasp_domain_identifier.as_str()
        )
    }
}

impl FromStr for DijetsId {
    type Err = DijetsIdParseError;

    fn from_str(s: &str) -> Result<Self, DijetsIdParseError> {
        let index = s
            .find('@')
            .ok_or_else(|| DijetsIdParseError::new("DijetsId does not have @".to_string()))?;
        let split = s.split_at(index);
        DijetsId::new_from_raw(split.0, &(split.1)[1..])
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct DijetsIdUserIdentifier(Box<str>);

impl DijetsIdUserIdentifier {
    pub fn new(s: &str) -> Result<Self, DijetsIdParseError> {
        if s.len() > 64 || s.is_empty() {
            return Err(DijetsIdParseError::new(
                "Invalid length for user identifier".to_string(),
            ));
        }

        let mut chars = s.chars();
        match chars.next() {
            Some('a'..='z') | Some('A'..='Z') | Some('0'..='9') => {}
            Some(_) => {
                return Err(DijetsIdParseError::new(
                    "Invalid user identifier input".to_string(),
                ))
            }
            None => {
                return Err(DijetsIdParseError::new(
                    "Invalid user identifier input".to_string(),
                ))
            }
        }
        for c in chars {
            match c {
                'a'..='z' | 'A'..='Z' | '0'..='9' | '.' => {}
                _ => return Err(DijetsIdParseError::new(format!("Invalid character {}", c))),
            }
        }
        Ok(DijetsIdUserIdentifier(s.into()))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl<'de> de::Deserialize<'de> for DijetsIdUserIdentifier {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: de::Deserializer<'de>,
    {
        use serde::de::Error;

        let s = <String>::deserialize(deserializer)?;
        DijetsIdUserIdentifier::new(&s).map_err(D::Error::custom)
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct DijetsIdVaspDomainIdentifier(Box<str>);

impl DijetsIdVaspDomainIdentifier {
    pub fn new(s: &str) -> Result<Self, DijetsIdParseError> {
        if s.len() > 63 || s.is_empty() {
            return Err(DijetsIdParseError::new(
                "Invalid length for vasp domain identifier".to_string(),
            ));
        }

        let mut chars = s.chars();
        match chars.next() {
            Some('a'..='z') | Some('A'..='Z') | Some('0'..='9') => {}
            Some(_) => {
                return Err(DijetsIdParseError::new(
                    "Invalid vasp domain input".to_string(),
                ))
            }
            None => {
                return Err(DijetsIdParseError::new(
                    "Invalid vasp domain input".to_string(),
                ))
            }
        }
        for c in chars {
            match c {
                'a'..='z' | 'A'..='Z' | '0'..='9' | '.' => {}
                _ => return Err(DijetsIdParseError::new(format!("Invalid character {}", c))),
            }
        }
        Ok(DijetsIdVaspDomainIdentifier(s.into()))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl<'de> de::Deserialize<'de> for DijetsIdVaspDomainIdentifier {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: de::Deserializer<'de>,
    {
        use serde::de::Error;

        let s = <String>::deserialize(deserializer)?;
        DijetsIdVaspDomainIdentifier::new(&s).map_err(D::Error::custom)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DijetsIdParseError {
    message: String,
}

impl DijetsIdParseError {
    fn new(message: String) -> DijetsIdParseError {
        DijetsIdParseError { message }
    }
}

impl Display for DijetsIdParseError {
    fn fmt(&self, f: &mut Formatter) -> std::fmt::Result {
        write!(f, "Unable to parse DijetsId: {}", self.message)
    }
}

impl std::error::Error for DijetsIdParseError {}

#[test]
fn test_invalid_user_identifier() {
    // Test valid domain
    let raw_identifier = "abcd1234";
    let identifier = DijetsIdUserIdentifier::new(raw_identifier);
    assert!(identifier.is_ok());

    // Test having 64 characters is valid
    let raw_identifier = "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffff1234";
    let identifier = DijetsIdUserIdentifier::new(raw_identifier);
    assert!(identifier.is_ok());

    // Test using "-" character is invalid
    let raw_identifier = "abcd!!!1234";
    let identifier = DijetsIdUserIdentifier::new(raw_identifier);
    assert_eq!(
        identifier.unwrap_err(),
        DijetsIdParseError {
            message: "Invalid character !".to_string()
        },
    );
    // Test having 64 characters is invalid
    let raw_identifier = "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffff12345";
    let identifier = DijetsIdUserIdentifier::new(raw_identifier);
    assert_eq!(
        identifier.unwrap_err(),
        DijetsIdParseError {
            message: "Invalid length for user identifier".to_string()
        },
    );
}

#[test]
fn test_invalid_vasp_domain_identifier() {
    // Test valid domain
    let raw_identifier = "dijets";
    let identifier = DijetsIdVaspDomainIdentifier::new(raw_identifier);
    assert!(identifier.is_ok());

    // Test having 63 characters is valid
    let raw_identifier = "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffff123";
    let identifier = DijetsIdVaspDomainIdentifier::new(raw_identifier);
    assert!(identifier.is_ok());

    // Test using "-" character is invalid
    let raw_identifier = "dijets-domain";
    let identifier = DijetsIdVaspDomainIdentifier::new(raw_identifier);
    assert_eq!(
        identifier.unwrap_err(),
        DijetsIdParseError {
            message: "Invalid character -".to_string()
        },
    );
    // Test having 64 characters is invalid
    let raw_identifier = "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggg";
    let identifier = DijetsIdVaspDomainIdentifier::new(raw_identifier);
    assert_eq!(
        identifier.unwrap_err(),
        DijetsIdParseError {
            message: "Invalid length for vasp domain identifier".to_string()
        },
    );
}

#[test]
fn test_get_dijets_id_string_from_components() {
    let user_identifier = DijetsIdUserIdentifier::new("username").unwrap();
    let vasp_domain_identifier = DijetsIdVaspDomainIdentifier::new("dijets").unwrap();
    let dijets_id = DijetsId::new(user_identifier, vasp_domain_identifier);
    let full_id = dijets_id.to_string();
    assert_eq!(full_id, "username@dijets");
}

#[test]
fn test_get_dijets_id_from_identifier_string() {
    let dijets_id_str = "username@dijets";
    let dijets_id = DijetsId::from_str(dijets_id_str).unwrap();
    assert_eq!(dijets_id.user_identifier().as_str(), "username");
    assert_eq!(dijets_id.vasp_domain_identifier().as_str(), "dijets");

    let dijets_id_str = "username@dijets.com";
    let dijets_id = DijetsId::from_str(dijets_id_str).unwrap();
    assert_eq!(dijets_id.user_identifier().as_str(), "username");
    assert_eq!(dijets_id.vasp_domain_identifier().as_str(), "dijets.com");

    let dijets_id_str = "username@dijets@com";
    let dijets_id = DijetsId::from_str(dijets_id_str);
    assert_eq!(
        dijets_id.unwrap_err(),
        DijetsIdParseError {
            message: "Invalid character @".to_string()
        },
    );

    let dijets_id_str = "username@@dijets.com";
    let dijets_id = DijetsId::from_str(dijets_id_str);
    assert_eq!(
        dijets_id.unwrap_err(),
        DijetsIdParseError {
            message: "Invalid vasp domain input".to_string()
        },
    );
}
