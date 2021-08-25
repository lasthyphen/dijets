//! account: bob, 0XUS

module {{default}}::Holder {
    struct Holder<T> has key { x: T }
    public fun hold<T: store>(account: &signer, x: T)  {
        move_to(account, Holder<T> { x })
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let xus = Dijets::mint<XUS>(account, 10000);
    assert(Dijets::value<XUS>(&xus) == 10000, 0);

    let (xus1, xus2) = Dijets::split(xus, 5000);
    assert(Dijets::value<XUS>(&xus1) == 5000 , 0);
    assert(Dijets::value<XUS>(&xus2) == 5000 , 2);
    let tmp = Dijets::withdraw(&mut xus1, 1000);
    assert(Dijets::value<XUS>(&xus1) == 4000 , 4);
    assert(Dijets::value<XUS>(&tmp) == 1000 , 5);
    Dijets::deposit(&mut xus1, tmp);
    assert(Dijets::value<XUS>(&xus1) == 5000 , 6);
    let xus = Dijets::join(xus1, xus2);
    assert(Dijets::value<XUS>(&xus) == 10000, 7);
    Holder::hold(account, xus);

    Dijets::destroy_zero(Dijets::zero<XUS>());
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    Dijets::destroy_zero(Dijets::mint<XUS>(account, 1));
}
}
// check: "Keep(ABORTED { code: 2055,"

//! new-transaction
//! sender: bob
//! gas-currency: XUS
script {
    use DijetsFramework::Dijets;
    use DijetsFramework::XUS::XUS;
    fun main()  {
        let coins = Dijets::zero<XUS>();
        Dijets::approx_xdx_for_coin<XUS>(&coins);
        Dijets::destroy_zero(coins);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
script {
    use DijetsFramework::Dijets;
    fun main()  {
        Dijets::destroy_zero(
            Dijets::zero<u64>()
        );
    }
}
// check: "Keep(ABORTED { code: 261"

//! new-transaction
script {
    use DijetsFramework::Dijets;
    use DijetsFramework::XDX::XDX;
    use DijetsFramework::XUS::XUS;
    fun main()  {
        assert(!Dijets::is_synthetic_currency<XUS>(), 9);
        assert(Dijets::is_synthetic_currency<XDX>(), 10);
        assert(!Dijets::is_synthetic_currency<u64>(), 11);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
    use DijetsFramework::Dijets;
    use DijetsFramework::XUS::XUS;
    use {{default}}::Holder;
    fun main(account: signer)  {
    let account = &account;
        Holder::hold(
            account,
            Dijets::remove_burn_capability<XUS>(account)
        );
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use Std::FixedPoint32;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let (mint_cap, burn_cap) = Dijets::register_currency<u64>(
        account, FixedPoint32::create_from_rational(1, 1), true, 10, 10, b"wat"
    );
    Dijets::publish_burn_capability(account, burn_cap);
    Holder::hold(account, mint_cap);
}
}
// check: "Keep(ABORTED { code: 258,"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use Std::FixedPoint32;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    let (mint_cap, burn_cap) = Dijets::register_currency<u64>(
        account, FixedPoint32::create_from_rational(1, 1), true, 10, 10, b"wat"
    );
    Holder::hold(account, mint_cap);
    Holder::hold(account, burn_cap);
}
}
// check: "Keep(ABORTED { code: 2,"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use Std::FixedPoint32;
fun main(account: signer) {
    let account = &account;
    Dijets::register_SCS_currency<u64>(
        account, account, FixedPoint32::create_from_rational(1, 1), 10, 10, b"wat"
    );
}
}
// check: "Keep(ABORTED { code: 258,"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use {{default}}::Holder;
fun main(account: signer) {
    let account = &account;
    Holder::hold(account, Dijets::create_preburn<XUS>(account));
}
}
// check: "Keep(ABORTED { code: 258,")

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use DijetsFramework::XDX::XDX;
fun main(account: signer) {
    let account = &account;
    Dijets::publish_preburn_queue_to_account<XDX>(account, account);
}
}
// check: "Keep(ABORTED { code: 1539,")

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    Dijets::publish_preburn_queue_to_account<XUS>(account, account);
}
}
// check: "Keep(ABORTED { code: 1539,")

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    let xus = Dijets::mint<XUS>(account, 1);
    let tmp = Dijets::withdraw(&mut xus, 10);
    Dijets::destroy_zero(tmp);
    Dijets::destroy_zero(xus);
}
}
// check: "Keep(ABORTED { code: 2568,"

//! new-transaction
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use DijetsFramework::XDX::XDX;
fun main() {
    assert(Dijets::is_SCS_currency<XUS>(), 99);
    assert(!Dijets::is_SCS_currency<XDX>(), 98);
    assert(!Dijets::is_synthetic_currency<XUS>(), 97);
    assert(Dijets::is_synthetic_currency<XDX>(), 96);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::CoreAddresses;
fun main(account: signer) {
    let account = &account;
    CoreAddresses::assert_currency_info(account)
}
}
// check: "Keep(ABORTED { code: 770,"

//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(tc_account: signer) {
    let tc_account = &tc_account;
    let max_u64 = 18446744073709551615;
    let coin1 = Dijets::mint<XUS>(tc_account, max_u64);
    let coin2 = Dijets::mint<XUS>(tc_account, 1);
    Dijets::deposit(&mut coin1, coin2);
    Dijets::destroy_zero(coin1);
}
}
// check: "Keep(ABORTED { code: 1800,"
