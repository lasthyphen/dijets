//! account: alice
script {
    use DijetsFramework::RegisteredCurrencies;
    fun main(account: signer) {
    let account = &account;
        RegisteredCurrencies::initialize(account);
    }
}
// check: "Keep(ABORTED { code: 1,"

//! new-transaction
//! sender: dijetsroot
script {
    use DijetsFramework::RegisteredCurrencies;
    fun main(account: signer) {
    let account = &account;
        RegisteredCurrencies::initialize(account);
    }
}
// check: "Keep(ABORTED { code: 1,"

//! new-transaction
//! sender: dijetsroot
script {
    use DijetsFramework::RegisteredCurrencies;
    fun main(account: signer) {
    let account = &account;
        RegisteredCurrencies::add_currency_code(account, b"XDX");
    }
}
// check: "Keep(ABORTED { code: 7,"
