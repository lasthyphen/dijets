//! account: alice
//! account: vivian, 100000, 0, validator
//! account: viola, 100000, 0, validator

// check that the validator account config works
script{
    use DijetsFramework::DijetsSystem;
    use Std::Signer;

    fun main(account: signer) {
    let account = &account;
        let sender = Signer::address_of(account);
        assert(!DijetsSystem::is_validator(sender), 1);
        assert(!DijetsSystem::is_validator(@{{alice}}), 2);
        assert(DijetsSystem::is_validator(@{{vivian}}), 3);
        assert(DijetsSystem::is_validator(@{{viola}}), 4);
        // number of validators should equal the number we declared
        assert(DijetsSystem::validator_set_size() == 2, 5);
        assert(DijetsSystem::get_ith_validator_address(1) == @{{vivian}}, 6);
        assert(DijetsSystem::get_ith_validator_address(0) == @{{viola}}, 7);
    }
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: vivian
script{
    use DijetsFramework::DijetsSystem;
    use Std::Signer;

    // check that sending from validator accounts works
    fun main(account: signer) {
    let account = &account;
        let sender = Signer::address_of(account);
        assert(DijetsSystem::is_validator(sender), 8);
    }
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsAccount;

    // register Alice as a validator candidate
    fun main(creator: signer) {
    let creator = &creator;
        DijetsAccount::create_validator_account(
            creator, @0xAA, x"00000000000000000000000000000000", b"owner_name"
        );
    }
}
// check: CreateAccountEvent
// check: "Keep(EXECUTED)"

// TODO(valerini): enable the following test once the sender format is supported
// //! new-transaction
// //! sender: 0xAA
// script{

//     // register Alice as a validator candidate, then rotate a key + check that it worked.
//     fun main(account: signer) {
//         // Alice registers as a validator candidate

//         // Rotating the consensus_pubkey should work

//         // Rotating the validator's full config
//     }
// }

// // check: "Keep(EXECUTED)"
