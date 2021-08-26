//! account: alice, 1000000
//! account: bob, 1000000

//! sender: alice
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<XUS>(&with_cap, @{{bob}}, 514, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
    assert(false, 42);
}
}
// check: "Keep(ABORTED { code: 42,"


//! new-transaction
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

fun main() {
    assert(DijetsAccount::balance<XUS>(@{{bob}}) == 1000000, 43);
}
}
// check: "Keep(EXECUTED)"
