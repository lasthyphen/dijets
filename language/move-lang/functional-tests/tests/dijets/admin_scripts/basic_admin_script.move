//! account: bob, 0, 0, vasp

//! sender: dijetsroot
//! execute-as: bob
script {
use Std::Signer;
fun main(dr: signer, bob: signer) {
    assert(Signer::address_of(&dr) == @DijetsRoot, 0);
    assert(Signer::address_of(&bob) == @{{bob}}, 1);
}
}

//! new-transaction
//! sender: blessed
//! execute-as: bob
script {
use Std::Signer;
fun main(dr: signer, bob: signer) {
    assert(Signer::address_of(&dr) == @TreasuryCompliance, 0);
    assert(Signer::address_of(&bob) == @{{bob}}, 1);
}
}
