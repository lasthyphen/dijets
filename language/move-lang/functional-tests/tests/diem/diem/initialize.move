//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    Dijets::initialize(account);
}
}
// check: "Keep(ABORTED { code: 1,"
