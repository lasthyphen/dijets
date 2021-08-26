//! sender: blessed
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::BCS;
fun main(account: signer) {
    let account = &account;
    let addr: address = @0x111101;
    assert(!DijetsAccount::exists_at(addr), 83);
    DijetsAccount::create_parent_vasp_account<XUS>(account, addr, BCS::to_bytes(&addr), x"aa", false);
}
}

//! new-transaction
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
fun main(account: signer) {
    let account = &account;
    let addr: address = @0x111101;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<XUS>(&with_cap, addr, 10, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
    assert(DijetsAccount::balance<XUS>(addr) == 10, 84);
    assert(DijetsAccount::sequence_number(addr) == 0, 84);
}
}
