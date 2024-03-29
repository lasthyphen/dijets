// Check that removing a non-existent validator aborts.

//! account: alice
//! account: bob, 1000000, 0, validator

//! sender: alice
script {
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        // alice cannot remove herself
        DijetsSystem::remove_validator(account, @{{alice}});
    }
}

// check: "Keep(ABORTED { code: 2,"

//! new-transaction
//! sender: alice
script {
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        // alice cannot remove bob
        DijetsSystem::remove_validator(account, @{{bob}});
    }
}

// check: "Keep(ABORTED { code: 2,"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        // bob cannot remove alice
        DijetsSystem::remove_validator(account, @{{alice}});
    }
}

// check: "Keep(ABORTED { code: 2,"
