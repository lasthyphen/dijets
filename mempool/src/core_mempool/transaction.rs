// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use dijets_types::{
    account_address::AccountAddress,
    transaction::{GovernanceRole, SignedTransaction},
};
use serde::{Deserialize, Serialize};
use std::time::Duration;

#[derive(Clone)]
pub struct MempoolTransaction {
    pub txn: SignedTransaction,
    // System expiration time of the transaction. It should be removed from mempool by that time.
    pub expiration_time: Duration,
    pub gas_amount: u64,
    pub ranking_score: u64,
    pub timeline_state: TimelineState,
    pub governance_role: GovernanceRole,
}

impl MempoolTransaction {
    pub(crate) fn new(
        txn: SignedTransaction,
        expiration_time: Duration,
        gas_amount: u64,
        ranking_score: u64,
        timeline_state: TimelineState,
        governance_role: GovernanceRole,
    ) -> Self {
        Self {
            txn,
            expiration_time,
            gas_amount,
            ranking_score,
            timeline_state,
            governance_role,
        }
    }
    pub(crate) fn get_sequence_number(&self) -> u64 {
        self.txn.sequence_number()
    }
    pub(crate) fn get_sender(&self) -> AccountAddress {
        self.txn.sender()
    }
    pub(crate) fn get_gas_price(&self) -> u64 {
        self.txn.gas_unit_price()
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug, Deserialize, Hash, Serialize)]
pub enum TimelineState {
    // The transaction is ready for broadcast.
    // Associated integer represents it's position in the log of such transactions.
    Ready(u64),
    // Transaction is not yet ready for broadcast, but it might change in a future.
    NotReady,
    // Transaction will never be qualified for broadcasting.
    // Currently we don't broadcast transactions originated on other peers.
    NonQualified,
}
