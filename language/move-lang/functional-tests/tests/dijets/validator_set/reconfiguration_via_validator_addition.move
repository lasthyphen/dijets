//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: invalidvalidator

//! block-prologue
//! proposer: bob
//! block-time: 2

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::remove_validator(account, @{{alice}});
        assert(!DijetsSystem::is_validator(@{{alice}}), 77);
        assert(DijetsSystem::is_validator(@{{bob}}), 78);
    }
}
// check: NewEpochEvent
// check: "Keep(EXECUTED)"

//! block-prologue
//! proposer: bob
//! block-time: 3

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
// bob cannot remove itself, only the dijets root account can remove validators from the set
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::remove_validator(account, @{{bob}});
    }
}
// check: "ABORTED { code: 2"

//! block-prologue
//! proposer: bob
//! block-time: 4

// check: "Keep(EXECUTED)"

//! new-transaction
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::add_validator(account, @{{alice}});
    }
}
// check: "ABORTED { code: 2,"

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::add_validator(account, @{{invalidvalidator}});
    }
}
// check: "ABORTED { code: 263,"

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::add_validator(account, @{{alice}});

        assert(DijetsSystem::is_validator(@{{alice}}), 77);
        assert(DijetsSystem::is_validator(@{{bob}}), 78);
    }
}
// check: NewEpochEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::add_validator(account, @{{alice}});
    }
}
// check: "ABORTED { code: 519,"
