//! account: vivian, 1000000, 0, validator
//! account: alice, 1000000, 0

//! block-prologue
//! proposer: vivian
//! block-time: 1000000

//! new-transaction
script{
use DijetsFramework::DijetsBlock;
use DijetsFramework::DijetsTimestamp;

fun main() {
    assert(DijetsBlock::get_current_block_height() == 1, 77);
    assert(DijetsTimestamp::now_microseconds() == 1000000, 78);
}
}

//! block-prologue
//! proposer: alice
//! block-time: 1000000
