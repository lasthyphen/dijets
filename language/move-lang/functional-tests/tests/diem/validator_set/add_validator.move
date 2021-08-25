// Add simple validator to DijetsSystem's validator set.

//! account: bob, 1000000, 0, validator
//! account: alex, 0, 0, address

//! sender: bob
script {
    use DijetsFramework::DijetsSystem;
    use DijetsFramework::ValidatorConfig;
    fun main() {
        // test bob is a validator
        assert(ValidatorConfig::is_valid(@{{bob}}) == true, 98);
        assert(DijetsSystem::is_validator(@{{bob}}) == true, 98);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::DijetsAccount;
fun main(creator: signer) {
    let creator = &creator;
//    DijetsAccount::create_validator_account(
//        creator, &r, 0xAA, x"00000000000000000000000000000000"
    DijetsAccount::create_validator_account(
        creator, @0xAA, x"00000000000000000000000000000000", b"owner_name"
    );

}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
//! args: 0, {{alex}}, {{alex::auth_key}}, b"alex"
stdlib_script::AccountCreationScripts::create_validator_account
// check: "Keep(EXECUTED)"

// TODO: ValidatorConfig::publish is now a friend function.
// Make this into a unit test.
// //! new-transaction
// //! sender: dijetsroot
// //! execute-as: alex
// script {
// use DijetsFramework::ValidatorConfig;
// fun main(dr_account: signer, alex_signer: signer) {
//     let dr_account = &dr_account;
//     let alex_signer = &alex_signer;
//     ValidatorConfig::publish(alex_signer, dr_account, b"alex");
// }
// }
// // check: "Discard(INVALID_WRITE_SET)"

//! new-transaction
script {
use DijetsFramework::ValidatorConfig;
fun main() {
    let _ = ValidatorConfig::get_config(@{{alex}});
}
}
// check: "Keep(ABORTED { code: 7,"

// TODO(valerini): enable the following test once the sender format is supported
// //! new-transaction
// //! sender: 0xAA
// script {
// fun main() {
//
//     // add itself as a validator
// }
// }
//
// // check: "Keep(EXECUTED)"
// // check: NewEpochEvent
