//! account: validator, 1000000, 0, validator
//! account: vasp, 0,0, address
//! account: child, 0,0, address
//! account: vivian, 0, 0, address
//! account: otto, 0, 0, address


// BEGIN: registration of a currency

//! new-transaction
//! sender: dijetsroot
// Change option to CustomModule
script {
use DijetsFramework::DijetsTransactionPublishingOption;
fun main(config: signer) {
    let config = &config;
    DijetsTransactionPublishingOption::set_open_module(config, false)
}
}
// check: "Keep(EXECUTED)"

//! block-prologue
//! proposer: validator
//! block-time: 3


//! new-transaction
//! sender: dijetsroot
address 0x1 {
module COIN {
    use Std::FixedPoint32;
    use DijetsFramework::Dijets;

    struct COIN has store { }

    public fun initialize(dr_account: &signer, tc_account: &signer) {
        // Register the COIN currency.
        Dijets::register_SCS_currency<COIN>(
            dr_account,
            tc_account,
            FixedPoint32::create_from_rational(1, 2), // exchange rate to XDX
            1000000, // scaling_factor = 10^6
            100,     // fractional_part = 10^2
            b"COIN",
        )
    }
}
}
// check: "Keep(EXECUTED)"

//! block-prologue
//! proposer: validator
//! block-time: 4

//! new-transaction
//! sender: dijetsroot
//! execute-as: blessed
script {
use DijetsFramework::TransactionFee;
use 0x1::COIN::{Self, COIN};
fun main(dr_account: signer, tc_account: signer) {
    let dr_account = &dr_account;
    let tc_account = &tc_account;
    COIN::initialize(dr_account, tc_account);
    TransactionFee::add_txn_fee_currency<COIN>(tc_account);
}
}
// check: "Keep(EXECUTED)"

// END: registration of a currency

// DijetsRoot should not be able to add a balance
//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::add_currency<XUS>(account);
}
}
// check: "Keep(ABORTED { code: 1031,"

// TreasuryCompliance should not be able to add a balance
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::add_currency<XUS>(account);
}
}
// check: "Keep(ABORTED { code: 1031,"


// Validators and ValidatorOperators should not be able to add a balance
//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::DijetsAccount;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::create_validator_account(account, @{{vivian}}, {{vivian::auth_key}}, b"owner_name");
    DijetsAccount::create_validator_operator_account(account, @{{otto}}, {{otto::auth_key}}, b"operator_name")

}
}
// check: "Keep(EXECUTED)"

// check Validator case
//! new-transaction
//! sender: vivian
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::add_currency<XUS>(account);
}
}
// check: "Keep(ABORTED { code: 1031,"

// check ValidatorOperator case
//! new-transaction
//! sender: otto
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::add_currency<XUS>(account);
}
}
// check: "Keep(ABORTED { code: 1031,"

//! new-transaction
//! sender: blessed
//! type-args: 0x1::XUS::XUS
//! args: 0, {{vasp}}, {{vasp::auth_key}}, b"bob", false
stdlib_script::AccountCreationScripts::create_parent_vasp_account
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: vasp
//! type-args: 0x1::COIN::COIN
stdlib_script::AccountAdministrationScripts::add_currency_to_account
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: vasp
//! type-args: 0x1::COIN::COIN
//! args: {{child}}, {{child::auth_key}}, false, 0
stdlib_script::AccountCreationScripts::create_child_vasp_account
// check: "Keep(EXECUTED)"

// can't add a balance of XDX right now
//! new-transaction
//! sender: child
//! type-args: 0x1::XDX::XDX
stdlib_script::AccountAdministrationScripts::add_currency_to_account
// check: "Keep(EXECUTED)"
