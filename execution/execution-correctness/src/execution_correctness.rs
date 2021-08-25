// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use consensus_types::block::Block;
use dijets_crypto::HashValue;
use dijets_types::ledger_info::LedgerInfoWithSignatures;
use executor_types::{Error, StateComputeResult};

/// Interface for ExecutionCorrectness.
/// It is basically the same as BlockExecutor except some interfaces will return signature with result.
pub trait ExecutionCorrectness: Send {
    fn committed_block_id(&self) -> Result<HashValue, Error>;

    fn reset(&self) -> Result<(), Error>;

    /// Executes a block.
    fn execute_block(
        &self,
        block: Block,
        parent_block_id: HashValue,
    ) -> Result<StateComputeResult, Error>;

    fn commit_blocks(
        &self,
        block_ids: Vec<HashValue>,
        ledger_info_with_sigs: LedgerInfoWithSignatures,
    ) -> Result<(), Error>;
}
