//! account: vivian, 1000000, 0, validator
//! account: dd1, 0, 0, address
//! account: dd2, 0, 0, address

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
//! proposer: vivian
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
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
use 0x1::COIN::COIN;
use DijetsFramework::Dijets;

// register dd(1|2) as a preburner
fun main(account: signer) {
    let account = &account;
    let prev_mcap1 = Dijets::market_cap<XUS>();
    let prev_mcap2 = Dijets::market_cap<COIN>();
    DijetsAccount::create_designated_dealer<XUS>(
        account,
        @{{dd1}},
        {{dd1::auth_key}},
        x"",
        false,
    );
    DijetsAccount::create_designated_dealer<COIN>(
        account,
        @{{dd2}},
        {{dd2::auth_key}},
        x"",
        false,
    );
    DijetsAccount::tiered_mint<XUS>(
        account,
        @{{dd1}},
        10,
        0,
    );
    DijetsAccount::tiered_mint<COIN>(
        account,
        @{{dd2}},
        100,
        0,
    );
    assert(Dijets::market_cap<XUS>() - prev_mcap1 == 10, 7);
    assert(Dijets::market_cap<COIN>() - prev_mcap2 == 100, 8);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dd1
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

// do some preburning
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::preburn<XUS>(account, &with_cap, 10);
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dd2
script {
use 0x1::COIN::COIN;
use DijetsFramework::DijetsAccount;

// do some preburning
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::preburn<COIN>(account, &with_cap, 100);
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(EXECUTED)"


// do some burning
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use 0x1::COIN::COIN;

fun main(account: signer) {
    let account = &account;
    let prev_mcap1 = Dijets::market_cap<XUS>();
    let prev_mcap2 = Dijets::market_cap<COIN>();
    Dijets::burn<XUS>(account, @{{dd1}}, 10);
    Dijets::burn<COIN>(account, @{{dd2}}, 100);
    assert(prev_mcap1 - Dijets::market_cap<XUS>() == 10, 9);
    assert(prev_mcap2 - Dijets::market_cap<COIN>() == 100, 10);
}
}
// check: "Keep(EXECUTED)"

// check that stop minting works
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;

fun main(account: signer) {
    let account = &account;
    Dijets::update_minting_ability<XUS>(account, false);
    let coin = Dijets::mint<XUS>(account, 10); // will abort here
    Dijets::destroy_zero(coin);
}
}
// check: "Keep(ABORTED { code: 1281,"
