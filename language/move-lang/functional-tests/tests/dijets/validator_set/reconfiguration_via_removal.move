//! account: alice
//! account: vivian, 1000000, 0, validator
//! account: viola, 1000000, 0, validator
//! account: v1, 1000000, 0, validator
//! account: v2, 1000000, 0, validator
//! account: v3, 1000000, 0, validator

//! block-prologue
//! proposer: viola
//! block-time: 2

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::remove_validator(account, @{{vivian}});
    }
}

// check: NewEpochEvent
// check: "Keep(EXECUTED)"

//! block-prologue
//! proposer: viola
//! block-time: 4

//! new-transaction
// check that Vivian is no longer a validator, Alice is not, but Viola is still a
// validator
script{
    use DijetsFramework::DijetsSystem;
    fun main() {
        assert(!DijetsSystem::is_validator(@{{vivian}}), 70);
        assert(!DijetsSystem::is_validator(@{{alice}}), 71);
        assert(DijetsSystem::is_validator(@{{viola}}), 72);
    }
}

// check: "Keep(EXECUTED)"
