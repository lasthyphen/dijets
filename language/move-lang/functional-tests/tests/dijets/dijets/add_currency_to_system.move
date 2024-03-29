//! account: vivian, 1000000, 0, validator
//! account: dd, 0, 0, address
//! account: bob, 0XUS, 0, vasp

//! new-transaction
//! sender: bob
//! gas-currency: COIN
script {
fun main() {}
}
// check: "Discard(CURRENCY_INFO_DOES_NOT_EXIST)"

//! block-prologue
//! proposer: vivian
//! block-time: 2

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
//! proposer: vivian
//! block-time: 3

// BEGIN: registration of a currency

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
//! proposer: vivian
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

//! new-transaction
//! sender: blessed
//! gas-currency: COIN
script {
use DijetsFramework::Dijets;
use 0x1::COIN::COIN;
use Std::FixedPoint32;
fun main(account: signer) {
    let account = &account;
    assert(Dijets::approx_xdx_for_value<COIN>(10) == 5, 1);
    assert(Dijets::scaling_factor<COIN>() == 1000000, 2);
    assert(Dijets::fractional_part<COIN>() == 100, 3);
    Dijets::update_xdx_exchange_rate<COIN>(account, FixedPoint32::create_from_rational(1, 3));
    assert(Dijets::approx_xdx_for_value<COIN>(10) == 3, 4);
}
}
// check: ToXDXExchangeRateUpdateEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::DijetsAccount;
use 0x1::COIN::COIN;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    let prev_mcap3 = Dijets::market_cap<COIN>();
    DijetsAccount::create_designated_dealer<COIN>(
        account,
        @{{dd}},
        {{dd::auth_key}},
        x"",
        false,
    );
    DijetsAccount::tiered_mint<COIN>(
        account,
        @{{dd}},
        10000,
        0,
    );
    assert(Dijets::market_cap<COIN>() - prev_mcap3 == 10000, 8);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
use DijetsFramework::DijetsAccount;
use 0x1::COIN::COIN;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::add_currency<COIN>(account);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dd
script {
use DijetsFramework::DijetsAccount;
use 0x1::COIN::COIN;
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::pay_from<COIN>(
        &with_cap,
        @{{bob}},
        10000,
        x"",
        x""
    );
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
//! gas-currency: COIN
//! gas-price: 1
script {
fun main() {}
}
// check: "Keep(EXECUTED)"
