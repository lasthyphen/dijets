// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! Forge is a framework for writing and running end-to-end tests in Dijets

pub use anyhow::Result;

mod interface;
pub use interface::*;

mod runner;
pub use runner::*;

mod backend;
pub use backend::*;

mod txn_emitter;
pub use txn_emitter::*;

mod report;
pub use report::*;
