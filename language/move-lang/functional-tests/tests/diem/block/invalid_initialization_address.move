script {
use DijetsFramework::DijetsBlock;
fun main(account: signer) {
    DijetsBlock::initialize_block_metadata(&account);
}
}
