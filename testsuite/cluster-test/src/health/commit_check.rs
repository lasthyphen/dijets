// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

use crate::health::{Event, HealthCheck, HealthCheckContext, ValidatorEvent};
use async_trait::async_trait;
use std::collections::{hash_map::Entry, HashMap, HashSet};

type EpochAndRound = (u64, u64);

/// Verifies that commit history produced by validators is 'lineariazble'
/// This means that validators can be behind each other, but commits that they are producing
/// do not contradict each other
#[derive(Default)]
pub struct CommitHistoryHealthCheck {
    epoch_round_to_commit: HashMap<EpochAndRound, CommitAndValidators>,
    latest_committed_epoch_round: HashMap<String, EpochAndRound>,
}

struct CommitAndValidators {
    pub hash: String,
    pub validators: HashSet<String>,
}

impl CommitHistoryHealthCheck {
    pub fn new() -> Self {
        Default::default()
    }
}

#[async_trait]
impl HealthCheck for CommitHistoryHealthCheck {
    fn on_event(&mut self, ve: &ValidatorEvent, ctx: &mut HealthCheckContext) {
        let commit = if let Event::Commit(ref commit) = ve.event {
            commit
        } else {
            return;
        };
        let round_to_commit = self.epoch_round_to_commit.entry(commit.epoch_and_round());
        match round_to_commit {
            Entry::Occupied(mut oe) => {
                let commit_and_validators = oe.get_mut();
                if commit_and_validators.hash != commit.commit {
                    ctx.report_failure(
                        ve.validator.clone(),
                        format!(
                            "produced contradicting commit {} at epoch_round {:?}, expected: {}",
                            commit.commit,
                            commit.epoch_and_round(),
                            commit_and_validators.hash
                        ),
                    );
                } else {
                    commit_and_validators
                        .validators
                        .insert(ve.validator.clone());
                }
            }
            Entry::Vacant(va) => {
                let mut validators = HashSet::new();
                validators.insert(ve.validator.clone());
                va.insert(CommitAndValidators {
                    hash: commit.commit.clone(),
                    validators,
                });
            }
        }
        let latest_committed_round = self
            .latest_committed_epoch_round
            .entry(ve.validator.clone());
        match latest_committed_round {
            Entry::Occupied(mut oe) => {
                let previous_epoch_and_round = *oe.get();
                if previous_epoch_and_round > commit.epoch_and_round() {
                    ctx.report_failure(
                        ve.validator.clone(),
                        format!(
                            "committed epoch and round {:?} after committing {:?}",
                            commit.epoch_and_round(),
                            previous_epoch_and_round
                        ),
                    );
                }
                oe.insert(commit.epoch_and_round());
            }
            Entry::Vacant(va) => {
                va.insert(commit.epoch_and_round());
            }
        }
        if let Some(min_round) = self.latest_committed_epoch_round.values().min() {
            self.epoch_round_to_commit.retain(|k, _v| *k >= *min_round);
        }
    }

    async fn verify(&mut self, _ctx: &mut HealthCheckContext) {}

    fn clear(&mut self) {
        self.epoch_round_to_commit.clear();
        self.latest_committed_epoch_round.clear();
    }

    fn name(&self) -> &'static str {
        "commit_check"
    }
}
