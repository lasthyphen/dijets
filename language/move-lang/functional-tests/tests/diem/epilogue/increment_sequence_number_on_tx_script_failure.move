//! account: default, 1000000, 0

script {
// When a transaction aborts, the sequence number should still be bumped up.
fun main() {
    assert(false, 77);
}
}
// check: "Keep(ABORTED { code: 77,"


//! new-transaction
script {
use DijetsFramework::DijetsAccount;
use Std::Signer;

fun main(account: signer) {
    let account = &account;
    let sender = Signer::address_of(account);
    assert(DijetsAccount::sequence_number(sender) == 1, 42);
}
}
// check: "Keep(EXECUTED)"
