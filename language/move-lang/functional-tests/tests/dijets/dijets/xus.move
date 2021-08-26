//! new-transaction
//! sender: blessed
script {
use DijetsFramework::Dijets;
use DijetsFramework::XUS::XUS;
use Std::FixedPoint32;
fun main(account: signer) {
    let account = &account;
    assert(Dijets::approx_xdx_for_value<XUS>(10) == 10, 1);
    assert(Dijets::scaling_factor<XUS>() == 1000000, 2);
    assert(Dijets::fractional_part<XUS>() == 100, 3);
    Dijets::update_xdx_exchange_rate<XUS>(account, FixedPoint32::create_from_rational(1, 3));
    assert(Dijets::approx_xdx_for_value<XUS>(10) == 3, 4);
}
}
// check: ToXDXExchangeRateUpdateEvent
// check: "Keep(EXECUTED)"
