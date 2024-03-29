//! account: default, 100000

module {{default}}::M {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::Dijets;
    use Std::Signer;

    struct R<T> has key { x: T }
    struct FakeCoin has store { value: u64 }

    fun fetch<T: store>(account: &signer): T acquires R {
        let R { x } = move_from<R<T>>(Signer::address_of(account));
        x
    }

    fun store<T: store>(account: &signer, x: T) {
        move_to(account, R { x });
    }

    fun transmute<T1: store, T2: store>(account: &signer, x: T1): T2 acquires R {
        store(account, x);
        fetch(account)
    }

    public fun become_rich(account: &signer) acquires R {
        let fake = FakeCoin { value: 400000 };
        let real = transmute(account, fake);
        Dijets::destroy_zero<XUS>(real);
    }
}

//! new-transaction
script {
use {{default}}::M;
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;
use Std::Signer;

fun main(account: signer) {
    let account = &account;
    M::become_rich(account);
    assert(DijetsAccount::balance<XUS>(Signer::address_of(account)) == 500000, 42);
}
}
// check: MISSING_DATA
