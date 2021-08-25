//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 3

//! new-transaction
script {
use DijetsFramework::DijetsTimestamp;

fun main() {
    assert(!DijetsTimestamp::is_genesis(), 10)
}
}
