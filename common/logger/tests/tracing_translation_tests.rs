// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use dijets_infallible::RwLock;
use dijets_logger::{DijetsLogger, Writer};
use std::sync::Arc;

#[derive(Default)]
struct VecWriter {
    logs: Arc<RwLock<Vec<String>>>,
}

impl Writer for VecWriter {
    fn write(&self, log: String) {
        self.logs.write().push(log)
    }
}

#[test]
fn verify_tracing_kvs() {
    // set up the dijets logger
    let writer = VecWriter::default();
    let logs = writer.logs.clone();
    DijetsLogger::builder()
        .is_async(false)
        .printer(Box::new(writer))
        .build();

    assert_eq!(logs.read().len(), 0);

    // log some messages
    tracing::error!("hello world");
    let s = logs.write().pop().unwrap();
    assert!(s.contains("ERROR"));
    assert!(s.contains("hello world"));

    tracing::info!("foo {} bar", 42);
    let s = logs.write().pop().unwrap();
    assert!(s.contains("INFO"));
    assert!(s.contains("foo 42 bar"));

    tracing::warn!(a = true, b = false);
    let s = logs.write().pop().unwrap();
    assert!(s.contains("WARN"));
    assert!(s.contains("true"));
    assert!(s.contains("false"));
}
