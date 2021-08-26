// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! This module defines error types used by [`DijetsDB`](crate::DijetsDB).

use thiserror::Error;

/// This enum defines errors commonly used among [`DijetsDB`](crate::DijetsDB) APIs.
#[derive(Debug, Error)]
pub enum DijetsDbError {
    /// A requested item is not found.
    #[error("{0} not found.")]
    NotFound(String),
    /// Requested too many items.
    #[error("Too many items requested: at least {0} requested, max is {1}")]
    TooManyRequested(u64, u64),
}
