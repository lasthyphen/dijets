script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::Signer;

fun main(account: signer) {
    let account = &account;
    let addr = Signer::address_of(account);
    let balance = DijetsAccount::balance<XUS>(addr);
    assert(balance > 10, 77);
}
}
