//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 100000000

//! new-transaction
script{
use DijetsFramework::DijetsBlock;
use DijetsFramework::DijetsTimestamp;

fun main() {
    assert(DijetsBlock::get_current_block_height() == 1, 76);
    assert(DijetsTimestamp::now_microseconds() == 100000000, 77);
}
}

//! block-prologue
//! proposer: vivian
//! block-time: 11000000
