//! account: alice, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator
//! account: viola, 1000000, 0, validator
//! account: bob, 0, 0, address
//! account: dave, 0, 0, address

//! block-prologue
//! proposer: vivian
//! block-time: 2

//! new-transaction
//! sender: dijetsroot
//! args: 0, {{bob}}, {{bob::auth_key}}, b"bob"
stdlib_script::AccountCreationScripts::create_validator_operator_account
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
//! args: 0, {{dave}}, {{dave::auth_key}}, b"dave"
stdlib_script::AccountCreationScripts::create_validator_operator_account
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
    use DijetsFramework::ValidatorConfig;
    fun main(account: signer) {
    let account = &account;
        // set bob to be alice's operator
        ValidatorConfig::set_operator(account, @{{bob}});
    }
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: viola
script {
    use DijetsFramework::ValidatorConfig;
    fun main(account: signer) {
    let account = &account;
        // set dave to be viola's operator
        ValidatorConfig::set_operator(account, @{{dave}});
    }
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script{
    use DijetsFramework::DijetsSystem;
    // Decertify two validators to make sure we can remove both
    // from the set and trigger reconfiguration
    fun main(account: signer) {
    let account = &account;
        assert(DijetsSystem::is_validator(@{{alice}}) == true, 98);
        assert(DijetsSystem::is_validator(@{{vivian}}) == true, 99);
        assert(DijetsSystem::is_validator(@{{viola}}) == true, 100);
        DijetsSystem::remove_validator(account, @{{vivian}});
        assert(DijetsSystem::is_validator(@{{alice}}) == true, 101);
        assert(DijetsSystem::is_validator(@{{vivian}}) == false, 102);
        assert(DijetsSystem::is_validator(@{{viola}}) == true, 103);
    }
}

// check: NewEpochEvent
// check: "Keep(EXECUTED)"

//! block-prologue
//! proposer: alice
//! block-time: 300000001

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dave
script{
    use DijetsFramework::DijetsSystem;
    use DijetsFramework::ValidatorConfig;
    // Two reconfigurations cannot happen in the same block
    fun main(account: signer) {
    let account = &account;
        // the local validator's key was the same as the key in the validator set
        assert(ValidatorConfig::get_consensus_pubkey(&DijetsSystem::get_validator_config(@{{viola}})) ==
               ValidatorConfig::get_consensus_pubkey(&ValidatorConfig::get_config(@{{viola}})), 99);
        ValidatorConfig::set_config(account, @{{viola}},
                                    x"d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a",
                                    x"", x"");
        // the local validator's key is now different from the one in the validator set
        assert(ValidatorConfig::get_consensus_pubkey(&DijetsSystem::get_validator_config(@{{viola}})) !=
               ValidatorConfig::get_consensus_pubkey(&ValidatorConfig::get_config(@{{viola}})), 99);
        let old_num_validators = DijetsSystem::validator_set_size();
        DijetsSystem::update_config_and_reconfigure(account, @{{viola}});
        assert(old_num_validators == DijetsSystem::validator_set_size(), 98);
        // the local validator's key is now the same as the key in the validator set
        assert(ValidatorConfig::get_consensus_pubkey(&DijetsSystem::get_validator_config(@{{viola}})) ==
               ValidatorConfig::get_consensus_pubkey(&ValidatorConfig::get_config(@{{viola}})), 99);
    }
}

// check: NewEpochEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script{
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        DijetsSystem::update_config_and_reconfigure(account, @{{viola}});
    }
}

// check: "Keep(ABORTED { code: 1031,"

//! new-transaction
//! sender: blessed
// freezing does not cause changes to the set
script {
    use DijetsFramework::DijetsSystem;
    use DijetsFramework::AccountFreezing;
    fun main(tc_account: signer) {
    let tc_account = &tc_account;
        assert(DijetsSystem::is_validator(@{{alice}}) == true, 101);
        AccountFreezing::freeze_account(tc_account, @{{alice}});
        assert(AccountFreezing::account_is_frozen(@{{alice}}), 1);
        assert(DijetsSystem::is_validator(@{{alice}}) == true, 102);
    }
}
// check: "Keep(EXECUTED)"
