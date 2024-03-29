//! account: default, 100000XUS

//! new-transaction
//! gas-price: 1
//! gas-currency: XUS
//! max-gas: 700
//! sender: default
script {
fun main() {
    loop {}
}
}
// check: "EXECUTION_FAILURE { status_code: OUT_OF_GAS,"
// check: "gas_used: 700,"
// check: "Keep(OUT_OF_GAS)"

//! new-transaction
//! sender: default
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
use Std::Signer;

fun main(account: signer) {
    let account = &account;
    let sender = Signer::address_of(account);
    assert(DijetsAccount::balance<XUS>(sender) == 100000 - 700, 42);
}
}
// check: "Keep(EXECUTED)"
