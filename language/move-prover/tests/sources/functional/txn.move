address 0x1 {

module TestTransaction {
    use Std::Signer;
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::DijetsTimestamp;

    spec module {
        pragma verify = true;
    }

    struct T has key {
        value: u128,
    }

    fun check_sender1(sender: &signer) {
        assert(Signer::address_of(sender) == @0xdeadbeef, 1);
    }
    spec check_sender1 {
        aborts_if Signer::spec_address_of(sender) != @0xdeadbeef;
    }

    fun check_sender2(sender: &signer) acquires T {
	    borrow_global<T>(Signer::address_of(sender));
    }
    spec check_sender2 {
        aborts_if !exists<T>(Signer::spec_address_of(sender));
    }

    fun exists_account(account: &signer) {
        DijetsTimestamp::assert_operating();
        assert(DijetsAccount::exists_at(Signer::address_of(account)), 1);
    }
    spec exists_account {
        include DijetsTimestamp::AbortsIfNotOperating;
        // TODO: we can remove the following line once we have the feature to inject
        // the postconditions of the "prologue" functions as invariants
        aborts_if !exists<DijetsAccount::DijetsAccount>(Signer::spec_address_of(account));
    }
}
}
