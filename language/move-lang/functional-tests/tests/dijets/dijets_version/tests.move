//! new-transaction
script{
use DijetsFramework::DijetsVersion;
fun main(account: signer) {
    let account = &account;
    DijetsVersion::initialize(account, 1);
}
}
// check: "Keep(ABORTED { code: 1,"

//! new-transaction
script{
use DijetsFramework::DijetsVersion;
fun main(account: signer) {
    let account = &account;
    DijetsVersion::set(account, 0);
}
}
// check: "Keep(ABORTED { code: 2,"

//! new-transaction
//! sender: dijetsroot
script{
use DijetsFramework::DijetsVersion;
fun main(account: signer) {
    let account = &account;
    DijetsVersion::set(account, 0);
}
}
// check: "Keep(ABORTED { code: 7,"
