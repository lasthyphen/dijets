//! new-transaction
script {
use DijetsFramework::TransactionFee;
fun main(account: signer) {
    let account = &account;
    TransactionFee::initialize(account);
}
}
// check: "Keep(ABORTED { code: 1,"
