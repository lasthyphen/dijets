//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 3

//! new-transaction
//! sender: dijetsroot
script {
    use DijetsFramework::DijetsSystem;
    fun main() {
        DijetsSystem::get_validator_config(@{{vivian}});
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script {
    use DijetsFramework::DijetsSystem;
    fun main(account: signer) {
    let account = &account;
        let num_validators = DijetsSystem::validator_set_size();
        assert(num_validators == 1, 98);
        let index = 0;
        while (index < num_validators) {
            let addr = DijetsSystem::get_ith_validator_address(index);
            DijetsSystem::remove_validator(account, addr);
            index = index + 1;
        };
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script {
    use DijetsFramework::DijetsSystem;
    fun main() {
        DijetsSystem::get_validator_config(@{{vivian}});
    }
}
// check: "Keep(ABORTED { code: 775,"
