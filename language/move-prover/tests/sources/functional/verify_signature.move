// This file is created to verify the native function in the standard BCS module.
module 0x42::VerifySignature {
    use DijetsFramework::Signature;


    public fun verify_ed25519_validate_pubkey(public_key: vector<u8>): bool {
        Signature::ed25519_validate_pubkey(public_key)
    }
    spec verify_ed25519_validate_pubkey {
        ensures result == Signature::ed25519_validate_pubkey(public_key);
    }

    public fun verify_ed25519_verify(
        signature: vector<u8>,
        public_key: vector<u8>,
        message: vector<u8>
    ): bool {
        Signature::ed25519_verify(signature, public_key, message)
    }
    spec verify_ed25519_verify {
        ensures result == Signature::ed25519_verify(signature, public_key, message);
    }
}
