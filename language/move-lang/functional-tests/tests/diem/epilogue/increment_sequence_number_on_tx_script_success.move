//! account: default, 1000000, 0

script {
fun main() {
}
}

// check: "Keep(EXECUTED)"


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
