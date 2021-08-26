//! account: bob, 1000000

script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::Signer;

fun main(sender: signer) {
    let sender = &sender;
    let sender_addr = Signer::address_of(sender);
    let recipient_addr = @{{bob}};
    let sender_original_balance = DijetsAccount::balance<XUS>(sender_addr);
    let recipient_original_balance = DijetsAccount::balance<XUS>(recipient_addr);
    let with_cap = DijetsAccount::extract_withdraw_capability(sender);
    DijetsAccount::pay_from<XUS>(&with_cap, recipient_addr, 5, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);

    let sender_new_balance = DijetsAccount::balance<XUS>(sender_addr);
    let recipient_new_balance = DijetsAccount::balance<XUS>(recipient_addr);
    assert(sender_new_balance == sender_original_balance - 5, 77);
    assert(recipient_new_balance == recipient_original_balance + 5, 77);
}
}
