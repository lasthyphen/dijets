// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use thiserror::Error;

/// Dijets Wallet Error is a convenience enum for generating arbitrary WalletErrors. Currently, only
/// the DijetsWalletGeneric error is being used, but there are plans to add more specific errors as
/// the Dijets Wallet matures
#[derive(Debug, Error)]
pub enum WalletError {
    /// generic error message
    #[error("{0}")]
    DijetsWalletGeneric(String),
}
