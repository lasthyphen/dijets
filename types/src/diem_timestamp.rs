// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use move_core_types::{
    ident_str,
    identifier::IdentStr,
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct DijetsTimestampResource {
    pub dijets_timestamp: DijetsTimestamp,
}

impl MoveStructType for DijetsTimestampResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("DijetsTimestamp");
    const STRUCT_NAME: &'static IdentStr = ident_str!("CurrentTimeMicroseconds");
}

impl MoveResource for DijetsTimestampResource {}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct DijetsTimestamp {
    pub microseconds: u64,
}
