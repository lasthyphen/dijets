script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::Signer;
fun main(account: signer) {
    let account = &account;
    let sender = Signer::address_of(account);

    // by default, an account has not delegated its withdrawal capability
    assert(!DijetsAccount::delegated_withdraw_capability(sender), 50);

    // make sure we report that the capability has been extracted
    let cap = DijetsAccount::extract_withdraw_capability(account);
    assert(DijetsAccount::delegated_withdraw_capability(sender), 51);

    // and the sender should be able to withdraw with this cap
    DijetsAccount::pay_from<XUS>(&cap, sender, 100, x"", x"");

    // restoring the capability should flip the flag back
    DijetsAccount::restore_withdraw_capability(cap);
    assert(!DijetsAccount::delegated_withdraw_capability(sender), 52);
}
}
