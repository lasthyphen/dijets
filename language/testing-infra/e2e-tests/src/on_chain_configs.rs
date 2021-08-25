// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{account::Account, executor::FakeExecutor};
use dijets_framework_releases::legacy::transaction_scripts::LegacyStdlibScript;
use dijets_types::{
    on_chain_config::DijetsVersion,
    transaction::{Script, TransactionArgument},
};
use dijets_vm::DijetsVM;

pub fn set_dijets_version(executor: &mut FakeExecutor, version: DijetsVersion) {
    let account = Account::new_genesis_account(dijets_types::on_chain_config::config_address());
    let txn = account
        .transaction()
        .script(Script::new(
            LegacyStdlibScript::UpdateDijetsVersion
                .compiled_bytes()
                .into_vec(),
            vec![],
            vec![
                TransactionArgument::U64(0),
                TransactionArgument::U64(version.major),
            ],
        ))
        .sequence_number(1)
        .sign();
    executor.new_block();
    executor.execute_and_apply(txn);

    let new_vm = DijetsVM::new(executor.get_state_view());
    assert_eq!(new_vm.internals().dijets_version().unwrap(), version);
}
