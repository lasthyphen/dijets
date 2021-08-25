//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 2

// disable txes from all accounts except DijetsRoot
//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::DijetsTransactionPublishingOption;
fun main(account: signer) {
    let account = &account;
    DijetsTransactionPublishingOption::halt_all_transactions(account);
}
}
// check: "Keep(EXECUTED)"

// sending custom script from normal account fails
//! new-transaction
script {
fun main() {
}
}
// check: "Discard(UNKNOWN_SCRIPT)"

// sending allowlisted script from normal account fails
//! new-transaction
//! args: b""
stdlib_script::AccountAdministrationScripts::rotate_authentication_key
// check: "Discard(UNKNOWN_SCRIPT)"

//! block-prologue
//! proposer: vivian
//! block-time: 3

// re-enable. this also tests that sending from DijetsRoot succeeds
//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::DijetsTransactionPublishingOption;
fun main(account: signer) {
    let account = &account;
    DijetsTransactionPublishingOption::resume_transactions(account);
}
}
// check: "Keep(EXECUTED)"

// sending from normal account succeeds again
//! new-transaction
//! args: b""
stdlib_script::AccountAdministrationScripts::rotate_authentication_key
// check: "Keep(ABORTED { code: 2055,"

// A normal account has insufficient privs to halt transactions
//! new-transaction
script {
use DijetsFramework::DijetsTransactionPublishingOption;
fun main(account: signer) {
    let account = &account;
    DijetsTransactionPublishingOption::halt_all_transactions(account);
}
}
// check: "Keep(ABORTED { code: 2,"
