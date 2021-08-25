script {
use DijetsFramework::DijetsAccount;

fun main() {
  // check that the sequence number of the Association account (which sent the genesis txn) has been
  // incremented...
  assert(DijetsAccount::sequence_number(@DijetsRoot) == 1, 66);
}
}
