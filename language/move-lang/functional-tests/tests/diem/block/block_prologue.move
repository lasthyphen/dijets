//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 1000000

// check: EventKey([17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 85, 12, 24])
// check: NewBlockEvent
// check: 1000000

//! new-transaction
script{
use DijetsFramework::DijetsTimestamp;
use DijetsFramework::DijetsBlock;

fun main() {
    assert(DijetsBlock::get_current_block_height() == 1, 73);
    assert(DijetsTimestamp::now_microseconds() == 1000000, 76);
}
}

//! new-transaction
script{
use DijetsFramework::DijetsTimestamp;

fun main() {
    assert(DijetsTimestamp::now_microseconds() != 2000000, 77);
}
}

//! new-transaction
//! sender: vivian
script{
use DijetsFramework::DijetsTimestamp;

fun main(account: signer) {
    let account = &account;
    DijetsTimestamp::update_global_time(account, @{{vivian}}, 20);
}
}
