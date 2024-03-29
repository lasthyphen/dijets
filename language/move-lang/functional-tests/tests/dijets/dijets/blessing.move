//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
// Make sure that XUS is registered. Make sure that the rules
// relating to SCS and synthetic currencies are consistent
fun main() {
    assert(Dijets::is_currency<XUS>(), 1);
    assert(!Dijets::is_synthetic_currency<XUS>(), 2);
    assert(Dijets::is_SCS_currency<XUS>(), 4);
    Dijets::assert_is_currency<XUS>();
    Dijets::assert_is_SCS_currency<XUS>();
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
script {
use DijetsFramework::Dijets;
use DijetsFramework::XDX::XDX;
fun main() {
    Dijets::assert_is_SCS_currency<XDX>();
}
}
// check: "Keep(ABORTED { code: 257,"

//! new-transaction
script {
use DijetsFramework::Dijets;
fun main() {
    Dijets::assert_is_currency<u64>();
}
}
// check: "Keep(ABORTED { code: 261,"

//! new-transaction
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use Std::FixedPoint32;
fun main(account: signer) {
    let account = &account;
    Dijets::update_xdx_exchange_rate<XUS>(account, FixedPoint32::create_from_rational(1, 3));
}
}
// check: "Keep(ABORTED { code: 258,"

//! new-transaction
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
fun main(account: signer) {
    let account = &account;
    Dijets::update_minting_ability<XUS>(account, false);
}
}
// check: "Keep(ABORTED { code: 258,"

//! new-transaction
module {{default}}::Holder {
    struct Holder<T> has key { x: T }
    public fun hold<T: store>(account: &signer, x: T) {
        move_to(account, Holder<T>{ x })
    }

    public fun get<T: store>(addr: address): T
    acquires Holder {
       let Holder<T> { x } = move_from<Holder<T>>(addr);
       x
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use Std::FixedPoint32;
use {{default}}::Holder;
fun main(dr_account: signer) {
    let dr_account = &dr_account;
    let (a, b) = Dijets::register_currency<XUS>(
        dr_account,
        FixedPoint32::create_from_rational(1, 1),
        false,
        1000,
        10,
        b"ABC",
    );

    Holder::hold(dr_account, a);
    Holder::hold(dr_account, b);
}
}
// check: "Keep(ABORTED { code: 262,"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use Std::FixedPoint32;
use {{default}}::Holder;
fun main(dr_account: signer) {
    let dr_account = &dr_account;
    let (a, b) = Dijets::register_currency<u64>(
        dr_account,
        FixedPoint32::create_from_rational(1,1),
        false,
        0, // scaling factor
        100,
        x""
    );
    Holder::hold(dr_account, a);
    Holder::hold(dr_account, b);
}
}
// check: "Keep(ABORTED { code: 263,"

//! new-transaction
//! sender: dijetsroot
script {
use DijetsFramework::Dijets;
use Std::FixedPoint32;
use {{default}}::Holder;
fun main(dr_account: signer) {
    let dr_account = &dr_account;
    let (a, b) = Dijets::register_currency<u64>(
        dr_account,
        FixedPoint32::create_from_rational(1,1),
        false,
        1000000000000000, // scaling factor > MAX_SCALING_FACTOR
        100,
        x""
    );
    Holder::hold(dr_account, a);
    Holder::hold(dr_account, b);
}
}
// check: "Keep(ABORTED { code: 263,"
