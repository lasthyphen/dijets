//! account: dd, 0, 0, address
//! account: baddd, 0, 0, address
// Test the end-to-end preburn-burn flow

// register blessed as a preburn entity
//! sender: blessed
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;

fun main(account: signer) {
    let account = &account;
    DijetsAccount::create_designated_dealer<XUS>(
        account,
        @{{dd}},
        {{dd::auth_key}},
        x"",
        false,
    );
    DijetsAccount::tiered_mint<XUS>(
        account,
        @{{dd}},
        600,
        0,
    );
}
}
// check: "Keep(EXECUTED)"

// perform two preburns, one with a value of 55 and the other 45
//! new-transaction
//! sender: dd
//! gas-currency: XUS
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
use DijetsFramework::DijetsAccount;
fun main(account: signer) {
    let account = &account;
    let old_market_cap = Dijets::market_cap<XUS>();
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    // send the coins to the preburn area. market cap should not be affected, but the preburn
    // bucket should increase in size by 100
    DijetsAccount::preburn<XUS>(account, &with_cap, 55);
    DijetsAccount::preburn<XUS>(account, &with_cap, 45);
    assert(Dijets::market_cap<XUS>() == old_market_cap, 8002);
    assert(Dijets::preburn_value<XUS>() == 100, 8003);
    DijetsAccount::pay_from<XUS>(&with_cap, @{{default}}, 2, x"", x"");
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: PreburnEvent
// check: "Keep(EXECUTED)"

// cancel the preburn, no matching value found so error
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer)  {
    let account = &account;
    DijetsAccount::cancel_burn<XUS>(account, @{{dd}}, 56);
}
}
// check: "Keep(ABORTED { code: 3073,"

// cancel the burn, but a zero value
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    // this should fail since the amount is 0
    Dijets::burn<XUS>(account, @{{dd}}, 0);
    }
}
// check: "Keep(ABORTED { code: 3073,"

// cancel the mutliple preburns
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer)  {
    let account = &account;
    DijetsAccount::cancel_burn<XUS>(account, @{{dd}}, 55);
    DijetsAccount::cancel_burn<XUS>(account, @{{dd}}, 45);
}
}
// check: CancelBurnEvent
// check: CancelBurnEvent
// check: "Keep(EXECUTED)"

// perform a preburn
//! new-transaction
//! sender: dd
//! gas-currency: XUS
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
use DijetsFramework::DijetsAccount;
fun main(account: signer) {
    let account = &account;
    let old_market_cap = Dijets::market_cap<XUS>();
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    // send the coins to the preburn area. market cap should not be affected, but the preburn
    // bucket should increase in size by 100
    DijetsAccount::preburn<XUS>(account, &with_cap, 100);
    assert(Dijets::market_cap<XUS>() == old_market_cap, 8002);
    assert(Dijets::preburn_value<XUS>() == 100, 8003);
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: PreburnEvent
// check: "Keep(EXECUTED)"

// second (concurrent) preburn allowed
//! new-transaction
//! sender: dd
//! gas-currency: XUS
script {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        // Preburn area already occupied, aborts
        DijetsAccount::preburn<XUS>(account, &with_cap, 200);
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: PreburnEvent
// check: "Keep(EXECUTED)"

// perform the burn from the blessed account, but wrong value
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    // this should fail since there isn't a preburn with a value of 300
    Dijets::burn<XUS>(account, @{{dd}}, 300);
    }
}
// check: "Keep(ABORTED { code: 3073,"

// perform the burn from the blessed account, but a zero value
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    // this should fail since the amount is 0
    Dijets::burn<XUS>(account, @{{dd}}, 0);
    }
}
// check: "Keep(ABORTED { code: 3073,"

// perform the burn from the blessed account
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    let old_market_cap = Dijets::market_cap<XUS>();
    // do the burn. the market cap should now decrease, and the preburn area should be empty
    Dijets::burn<XUS>(account, @{{dd}}, 100);
    Dijets::burn<XUS>(account, @{{dd}}, 200);
    assert(Dijets::market_cap<XUS>() == old_market_cap - 300, 8004);
    assert(Dijets::preburn_value<XUS>() == 0, 8005);
    }
}
// check: BurnEvent
// check: BurnEvent
// check: "Keep(EXECUTED)"

// Preburn allowed but larger than balance
//! new-transaction
//! sender: dd
//! gas-currency: XUS
script {
    use DijetsFramework::XUS::XUS;
    // use DijetsFramework::Dijets;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::preburn<XUS>(account, &with_cap, 501);
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 1288,"

// Try to burn on an account that doesn't have a preburn queue resource
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    Dijets::burn<XUS>(account, @{{default}}, 0);
}
}
// check: "Keep(ABORTED { code: 2821,"

// Try to burn on an account that doesn't have a burn capability
//! new-transaction
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    Dijets::burn<XUS>(account, @{{default}}, 0);
}
}
// check: "Keep(ABORTED { code: 4,"

// Try to cancel burn on an account that doesn't have a burn capability
//! new-transaction
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::Dijets;
fun main(account: signer) {
    let account = &account;
    Dijets::destroy_zero(Dijets::cancel_burn<XUS>(account, @{{dd}}, 0));
}
}
// check: "Keep(ABORTED { code: 4,"

// Try to preburn to an account that doesn't have a preburn resource
//! new-transaction
script {
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::preburn<XUS>(account, &with_cap, 1);
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(ABORTED { code: 1539,"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XDX::XDX;
fun main(account: signer) {
    let account = &account;
    DijetsAccount::create_designated_dealer<XDX>(
        account,
        @{{baddd}},
        {{baddd::auth_key}},
        x"",
        false,
    );
}
}
// check: "Keep(ABORTED { code: 1543,"

//! new-transaction
module {{default}}::Holder {
    struct Holder<T> has key {
        a: T,
        b: T,
    }

    public fun hold<T: store>(account: &signer, a: T, b: T) {
        move_to(account, Holder<T>{ a, b})
    }

    public fun get<T: store>(addr: address): (T, T)
    acquires Holder {
        let Holder { a, b} = move_from<Holder<T>>(addr);
        (a, b)
    }
}

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let u64_max = 18446744073709551615;
    Holder::hold(
        account,
        Dijets::mint<XUS>(account, u64_max),
        Dijets::mint<XUS>(account, u64_max)
    );
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dd
script {
use DijetsFramework::Dijets::{Self, Dijets};
use DijetsFramework::XUS::XUS;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let (xus, coin2) = Holder::get<Dijets<XUS>>(@{{blessed}});
    Dijets::preburn_to(account, xus);
    Dijets::preburn_to(account, coin2);
}
}
// check: "Keep(ABORTED { code: 1800,"

//! new-transaction
//! sender: dd
script {
use DijetsFramework::DijetsAccount;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    let with_cap = DijetsAccount::extract_withdraw_capability(account);
    DijetsAccount::preburn<XUS>(account, &with_cap, 1);
    DijetsAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(EXECUTED)"

// Limit exceeded on coin deposit
//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    Dijets::burn<XUS>(account, @{{dd}}, 1);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    Dijets::publish_burn_capability(
        account,
        Dijets::remove_burn_capability<XUS>(account)
    );
}
}
// check: "Keep(ABORTED { code: 4,"

//! new-transaction
//! sender: dd
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let index = 0;
    let max_outstanding_requests = 256;
    let (xus1, xus2) = Holder::get<Dijets::Dijets<XUS>>(@{{blessed}});
    while (index < max_outstanding_requests) {
        Dijets::preburn_to(account, Dijets::withdraw(&mut xus1, 1));
        index = index + 1;
    };
    Dijets::preburn_to(account, Dijets::withdraw(&mut xus1, 1));
    Holder::hold(account, xus1, xus2);
}
}
// check: "Keep(ABORTED { code: 2824,"

// Preburn allowed but amount is zero so aborts
//! new-transaction
//! sender: dd
//! gas-currency: XUS
script {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::preburn<XUS>(account, &with_cap, 0);
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 1799,"
