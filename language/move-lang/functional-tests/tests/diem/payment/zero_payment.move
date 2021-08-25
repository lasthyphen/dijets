script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::Signer;

fun main(account: signer) {
    let account = &account;
    let addr = Signer::address_of(account);
    let old_balance = DijetsAccount::balance<XUS>(addr);

    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<XUS>(&with_cap, addr, 0, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);

    assert(DijetsAccount::balance<XUS>(addr) == old_balance, 42);
}
}
// check: "Keep(ABORTED { code: 519,"
