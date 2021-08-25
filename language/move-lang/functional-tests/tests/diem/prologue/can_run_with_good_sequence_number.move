//! account: alice, 10000, 10

//! sequence-number: 10
//! sender: alice
script {
use DijetsFramework::DijetsAccount;

fun main() {
    assert(DijetsAccount::sequence_number(@{{alice}}) == 10, 72);
}
}
// check: "Keep(EXECUTED)"
