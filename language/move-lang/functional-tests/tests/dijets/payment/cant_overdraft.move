//! account: alice, 0, 0, 0XUS

script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::Signer;

fun main(account: signer) {
    let account = &account;
    let addr = Signer::address_of(account);
    let sender_balance = DijetsAccount::balance<XUS>(addr);
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<XUS>(&with_cap, @{{alice}}, sender_balance, x"", x"");

    assert(DijetsAccount::balance<XUS>(addr) == 0, 42);

    DijetsAccount::pay_from<XUS>(&with_cap, @{{alice}}, sender_balance, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(ABORTED { code: 1288,"
