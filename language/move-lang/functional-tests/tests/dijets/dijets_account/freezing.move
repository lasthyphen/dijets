//! account: bob
//! account: vasp, 0, 0, address
//! account: child, 0, 0, address
//! account: alice, 0, 0, address

// Keep these tests until adding unit tests for the prologue and Dijets Account around freezing
// We need to keep some of them to test for events as well

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::AccountFreezing;
// Make sure we can freeze and unfreeze accounts.
fun main(account: signer) {
    let account = &account;
    AccountFreezing::freeze_account(account, @{{bob}});
}
}

// check: FreezeAccountEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
fun main() { }
}
// check: SENDING_ACCOUNT_FROZEN

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::AccountFreezing::{Self};
fun main(account: signer) {
    let account = &account;
    AccountFreezing::unfreeze_account(account, @{{bob}});
}
}
// check: UnfreezeAccountEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
fun main() { }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::AccountFreezing::{Self};
fun main(account: signer) {
    let account = &account;
    AccountFreezing::freeze_account(account, @{{dijetsroot}});
}
}
// check: "Keep(ABORTED { code: 775,"

// This replaces the transaction below, which was commented out because the
// function is now "friend", to make the rest of the script work.
//! new-transaction
//! sender: blessed
//! type-args: 0x1::XUS::XUS
//! args: 0, {{vasp}}, {{vasp::auth_key}}, b"bob", true
stdlib_script::AccountCreationScripts::create_parent_vasp_account
// check: "Keep(EXECUTED)"

// TODO: this can go away once //! account works
// create a parent VASPx

// TODO: DijetsAccount::create_parent_vasp_account is now a friend function
// and cannot be accessed.  Commented out (not deleted) because it will become
// a unit test
// // TODO: this can go away once //! account works
// // create a parent VASPx
// //! new-transaction
// //! sender: blessed
// script {
// use DijetsFramework::DijetsAccount;
// use DijetsFramework::XUS::XUS;
// fun main(dr_account: signer) {
//     let dr_account = &dr_account;
//     DijetsAccount::create_parent_vasp_account<XUS>(
//         dr_account,
//         @{{vasp}},
//         {{vasp::auth_key}},
//         x"0A",
//         true,
//     );
// }
// }
// // check: "Keep(EXECUTED)"

//! new-transaction
//! sender: vasp
//! type-args: 0x1::XUS::XUS
//! args: {{child}}, {{child::auth_key}}, true, 0
stdlib_script::AccountCreationScripts::create_child_vasp_account
// check: "Keep(EXECUTED)"

// TODO: DijetsAccount::create_child_vasp_account is a friend function
// // create a child VASP
// //! new-transaction
// //! sender: vasp
// script {
// use DijetsFramework::DijetsAccount;
// use DijetsFramework::XUS::XUS;
// fun main(parent_vasp: signer) {
//     let parent_vasp = &parent_vasp;
//     let dummy_auth_key_prefix = x"00000000000000000000000000000000";
//     DijetsAccount::create_child_vasp_account<XUS>(parent_vasp, @{{child}}, dummy_auth_key_prefix, false);
// }
// }
// // check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::AccountFreezing;
// Freezing a child account doesn't freeze the root, freezing the root
// doesn't freeze the child
fun main(account: signer) {
    let account = &account;
    AccountFreezing::freeze_account(account, @{{child}});
    assert(AccountFreezing::account_is_frozen(@{{child}}), 3);
    assert(!AccountFreezing::account_is_frozen(@{{vasp}}), 4);
    AccountFreezing::unfreeze_account(account, @{{child}});
    assert(!AccountFreezing::account_is_frozen(@{{child}}), 5);
    AccountFreezing::freeze_account(account, @{{vasp}});
    assert(AccountFreezing::account_is_frozen(@{{vasp}}), 6);
    assert(!AccountFreezing::account_is_frozen(@{{child}}), 7);
    AccountFreezing::unfreeze_account(account, @{{vasp}});
    assert(!AccountFreezing::account_is_frozen(@{{vasp}}), 8);
}
}

// check: FreezeAccountEvent
// check: UnfreezeAccountEvent
// check: "Keep(EXECUTED)"

//! new-transaction
module {{default}}::Holder {
    struct Holder<T> has key { x: T }
    public fun hold<T: store>(account: &signer, x: T) {
        move_to(account, Holder<T>{ x })
    }

    public fun get<T: store>(addr: address): T
    acquires Holder {
       let Holder<T> { x } = move_from<Holder<T>>(addr);
       x
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: vasp
script {
use DijetsFramework::DijetsAccount;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let cap = DijetsAccount::extract_withdraw_capability(account);
    Holder::hold(account, cap);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
    use DijetsFramework::AccountFreezing;
    fun main(account: signer) {
        let account = &account;
        AccountFreezing::freeze_account(account, @{{vasp}});
        assert(AccountFreezing::account_is_frozen(@{{vasp}}), 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
    use DijetsFramework::AccountFreezing;
    fun main(account: signer) {
        let account = &account;
        AccountFreezing::freeze_account(account, @{{vasp}});
        assert(AccountFreezing::account_is_frozen(@{{vasp}}), 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
//! type-args: 0x1::XUS::XUS
//! args: 0, {{alice}}, {{alice::auth_key}}, b"bob", true
stdlib_script::AccountCreationScripts::create_parent_vasp_account
//! check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
    use {{default}}::Holder;
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::XUS::XUS;
    fun main(account: signer) {
        let account = &account;
        let cap = Holder::get<DijetsAccount::WithdrawCapability>(@{{vasp}});
        DijetsAccount::pay_from<XUS>(&cap, @{{alice}}, 0, x"", x"");
        Holder::hold(account, cap);
    }
}
// check: "Keep(ABORTED { code: 1281,"

//! new-transaction
//! sender: alice
script {
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::XUS::XUS;
    fun main(account: signer) {
        let account = &account;
        let cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XUS>(&cap, @{{vasp}}, 0, x"", x"");
        DijetsAccount::restore_withdraw_capability(cap);
    }
}
// check: "Keep(ABORTED { code: 1281,"

//! new-transaction
//! sender: alice
script {
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::XUS::XUS;
    fun main(account: signer) {
        let account = &account;
        let cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XUS>(&cap, @{{vasp}}, 0, x"", x"");
        DijetsAccount::restore_withdraw_capability(cap);
    }
}
// check: "Keep(ABORTED { code: 1281,"

// TODO: make into unit test
// //! new-transaction
// //! sender: alice
// script {
// use DijetsFramework::AccountFreezing;
// fun main(account: signer) {
//     let account = &account;
//     AccountFreezing::create(account);
// }
// }
// // check: "Keep(ABORTED { code: 518,"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::AccountFreezing;
fun main(account: signer) {
    let account = &account;
    AccountFreezing::freeze_account(account, @0x0);
}
}
// check: "Keep(ABORTED { code: 517,"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::AccountFreezing;
fun main(account: signer) {
    let account = &account;
    AccountFreezing::unfreeze_account(account, @0x0);
}
}
// check: "Keep(ABORTED { code: 517,"
