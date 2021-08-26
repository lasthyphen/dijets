// Check that the add_all_currencies flag does the expected thing


//! new-transaction
//! sender: blessed
script {
    use DijetsFramework::DualAttestation;
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::XDX::XDX;
    fun main(account: signer) {
    let account = &account;
        let dummy_auth_key_prefix = x"00000000000000000000000000000001";
        DijetsAccount::create_designated_dealer<XUS>(
            account, @0x2, copy dummy_auth_key_prefix, b"name", false
        );
        DijetsAccount::create_designated_dealer<XUS>(
            account, @0x3, dummy_auth_key_prefix, b"other_name", true
        );

        assert(DijetsAccount::accepts_currency<XUS>(@0x2), 0);
        assert(!DijetsAccount::accepts_currency<XDX>(@0x2), 2);
        assert(DualAttestation::human_name(@0x2) == b"name", 77);
        assert(DualAttestation::base_url(@0x2) == b"", 78);
        assert(DualAttestation::compliance_public_key(@0x2) == b"", 79);

        assert(DijetsAccount::accepts_currency<XUS>(@0x3), 3);
        assert(DijetsAccount::accepts_currency<XDX>(@0x3), 5);
    }
}

// check: "Keep(EXECUTED)"
