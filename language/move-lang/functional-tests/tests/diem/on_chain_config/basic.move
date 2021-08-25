//! new-transaction
script {
    use DijetsFramework::DijetsConfig::{Self};
    fun main(account: signer) {
    let account = &account;
        DijetsConfig::initialize(account);
    }
}
// check: "Keep(ABORTED { code: 1,"

//! new-transaction
script {
    use DijetsFramework::DijetsConfig;
    fun main() {
        let _x = DijetsConfig::get<u64>();
    }
}
// check: "Keep(ABORTED { code: 261,"

//! new-transaction
script {
    use DijetsFramework::DijetsConfig;
    fun main(account: signer) {
    let account = &account;
        DijetsConfig::set(account, 0);
    }
}
// check: "Keep(ABORTED { code: 516,"

//! new-transaction
script {
    use DijetsFramework::DijetsConfig::{Self};
    fun main(account: signer) {
    let account = &account;
        DijetsConfig::publish_new_config(account, 0);
    }
}
// check: "Keep(ABORTED { code: 2,"
