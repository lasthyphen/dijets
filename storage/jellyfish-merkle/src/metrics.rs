// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use dijets_metrics::{register_int_counter, IntCounter};
use once_cell::sync::Lazy;

pub static DIJETS_JELLYFISH_LEAF_ENCODED_BYTES: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "dijets_jellyfish_leaf_encoded_bytes",
        "Dijets jellyfish leaf encoded bytes in total"
    )
    .unwrap()
});

pub static DIJETS_JELLYFISH_INTERNAL_ENCODED_BYTES: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "dijets_jellyfish_internal_encoded_bytes",
        "Dijets jellyfish total internal nodes encoded in bytes"
    )
    .unwrap()
});

pub static DIJETS_JELLYFISH_STORAGE_READS: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!(
        "dijets_jellyfish_storage_reads",
        "Dijets jellyfish reads from storage"
    )
    .unwrap()
});
