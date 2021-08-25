script {
use DijetsFramework::DijetsAccount;
use Std::Signer;
fun main(account: signer) {
    let account = &account;
    let sender = Signer::address_of(account);
    let old_auth_key = DijetsAccount::authentication_key(sender);

    // by default, an account has not delegated its key rotation capability
    assert(!DijetsAccount::delegated_key_rotation_capability(sender), 50);

    // extracting the capability should flip the flag
    let cap = DijetsAccount::extract_key_rotation_capability(account);
    assert(DijetsAccount::delegated_key_rotation_capability(sender), 51);

    // and the sender should be able to rotate
    DijetsAccount::rotate_authentication_key(&cap, old_auth_key);

    // restoring the capability should flip the flag back
    DijetsAccount::restore_key_rotation_capability(cap);
    assert(!DijetsAccount::delegated_key_rotation_capability(sender), 52);
}
}
// check: "Keep(EXECUTED)"

// Extracting the capability should preclude rotation
//! new-transaction
script {
use DijetsFramework::DijetsAccount;
fun main(account: signer) {
    let account = &account;
    let cap = DijetsAccount::extract_key_rotation_capability(account);
    let cap2 = DijetsAccount::extract_key_rotation_capability(account);

    // should fail
    DijetsAccount::rotate_authentication_key(&cap2, x"00");
    DijetsAccount::restore_key_rotation_capability(cap);
    DijetsAccount::restore_key_rotation_capability(cap2);
}
}
// check: "Keep(ABORTED { code: 2305,"
// check: location: ::DijetsAccount
