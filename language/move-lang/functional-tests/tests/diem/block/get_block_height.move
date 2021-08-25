//! account: vivian, 1000000, 0, validator
//! new-transaction

script{
use DijetsFramework::DijetsBlock;
fun main() {
    // check that the height of the initial block is zero
    assert(DijetsBlock::get_current_block_height() == 0, 77);
}
}

//! block-prologue
//! proposer: vivian
//! block-time: 100000000

//! new-transaction
script{
use DijetsFramework::DijetsBlock;
use DijetsFramework::DijetsTimestamp;

fun main() {
    assert(DijetsBlock::get_current_block_height() == 1, 76);
    assert(DijetsTimestamp::now_microseconds() == 100000000, 80);
}
}

//! block-prologue
//! proposer: vivian
//! block-time: 101000000

//! new-transaction
script{
use DijetsFramework::DijetsBlock;
use DijetsFramework::DijetsTimestamp;

fun main() {
    assert(DijetsBlock::get_current_block_height() == 2, 76);
    assert(DijetsTimestamp::now_microseconds() == 101000000, 80);
}
}
