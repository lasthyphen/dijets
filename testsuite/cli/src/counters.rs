// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use dijets_metrics::{register_int_counter, IntCounter};
use once_cell::sync::Lazy;

// Client counters
pub static COUNTER_CLIENT_ERRORS: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "COUNTER_CLIENT_ERRORS",
        "Number of errors encountered by Client"
    )
    .unwrap()
});
