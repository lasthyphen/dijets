//! new-transaction
//! account: alice
//! account: bob
//! sender: alice
//! secondary-signers: bob
//! args: 10
script {
use DijetsFramework::DijetsAccount;
use Std::Signer;
use DijetsFramework::XUS;

fun main(alice: signer, bob: signer, amount: u64) {
    let alice_withdrawal_cap = DijetsAccount::extract_withdraw_capability(&alice);
    let bob_addr = Signer::address_of(&bob);
    DijetsAccount::pay_from<XUS::XUS>(
        &alice_withdrawal_cap, bob_addr, amount, x"", x""
    );
    DijetsAccount::restore_withdraw_capability(alice_withdrawal_cap);
}
}
