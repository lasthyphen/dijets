//! account: alice
//! account: bob
//! account: carol

//! sender: alice
module {{alice}}::SillyColdWallet {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::Dijets;
    use Std::Signer;

    struct T has key {
        cap: DijetsAccount::WithdrawCapability,
        owner: address,
    }

    public fun publish(account: &signer, cap: DijetsAccount::WithdrawCapability, owner: address) {
        move_to(account, T { cap, owner });
    }

    public fun withdraw(account: &signer, wallet_address: address, _amount: u64): Dijets::Dijets<XUS> acquires T {
        let wallet_ref = borrow_global_mut<T>(wallet_address);
        let sender = Signer::address_of(account);
        assert(wallet_ref.owner == sender, 77);
        // TODO: the withdraw_from API is no longer exposed in DijetsAccount
        Dijets::zero()
    }
}

//! new-transaction
//! sender: alice
script {
use {{alice}}::SillyColdWallet;
use DijetsFramework::DijetsAccount;

// create a cold wallet for Bob that withdraws from Alice's account
fun main(sender: signer) {
    let sender = &sender;
    let cap = DijetsAccount::extract_withdraw_capability(sender);
    SillyColdWallet::publish(sender, cap, @{{bob}});
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

// check that Alice can no longer withdraw from her account
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    // should fail with withdrawal capability already extracted
    DijetsAccount::pay_from<XUS>(&with_cap, @{{alice}}, 1000, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(ABORTED { code: 1793,"

//! new-transaction
//! sender: bob
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

// check that Bob can still withdraw from his normal account
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<XUS>(&with_cap, @{{bob}}, 1000, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}

//! new-transaction
//! sender: carol
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

// check that other users can still pay into Alice's account in the normal way
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<XUS>(&with_cap, @{{alice}}, 1000, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
