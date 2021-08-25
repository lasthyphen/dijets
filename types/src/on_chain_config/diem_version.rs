// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::on_chain_config::OnChainConfig;
use serde::{Deserialize, Serialize};

/// Defines the version of Dijets Validator software.
#[derive(Clone, Debug, Deserialize, PartialEq, Eq, PartialOrd, Ord, Serialize)]
pub struct DijetsVersion {
    pub major: u64,
}

impl OnChainConfig for DijetsVersion {
    const IDENTIFIER: &'static str = "DijetsVersion";
}

// NOTE: version number for release 1.2 Dijets
// Items gated by this version number include:
//  - the ScriptFunction payload type
pub const DIJETS_VERSION_2: DijetsVersion = DijetsVersion { major: 2 };

// NOTE: version number for release 1.3 of Dijets
// Items gated by this version number include:
//  - Multi-agent transactions
pub const DIJETS_VERSION_3: DijetsVersion = DijetsVersion { major: 3 };

// Maximum current known version
pub const DIJETS_MAX_KNOWN_VERSION: DijetsVersion = DIJETS_VERSION_3;
