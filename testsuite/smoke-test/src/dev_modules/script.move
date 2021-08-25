// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

// Note: If this test file fails to run, it is possible that the
// compiled version of the Move stdlib needs to be updated. This code
// is compiled with the latest compiler and stdlib, but it runs with
// the compiled stdlib.

script {
use DijetsFramework::Dijets;
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
use {{sender}}::MyModule;

fun main(account: signer, recipient: address, amount: u64) {
    let with_cap = DijetsAccount::extract_withdraw_capability(&account);
    DijetsAccount::pay_from<XUS>(&with_cap, recipient, amount, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
    let coin = MyModule::id<XUS>(Dijets::zero<XUS>());
    Dijets::destroy_zero(coin)
}
}
