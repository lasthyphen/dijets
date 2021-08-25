//! account: alice
//! account: bob
//! account: carol

//! sender: alice
module {{alice}}::AlicePays {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::DijetsAccount;

    struct T has key {
        cap: DijetsAccount::WithdrawCapability,
    }

    public fun create(sender: &signer) {
        move_to(sender, T {
            cap: DijetsAccount::extract_withdraw_capability(sender),
        })
    }

    public fun pay(payee: address, amount: u64) acquires T {
        let t = borrow_global<T>(@{{alice}});
        DijetsAccount::pay_from<XUS>(
            &t.cap,
            payee,
            amount,
            x"0A11CE",
            x""
        )
    }
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
use {{alice}}::AlicePays;
fun main(sender: signer) {
    let sender = &sender;
    AlicePays::create(sender)
}
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
use {{alice}}::AlicePays;
use DijetsFramework::XUS::XUS;
use DijetsFramework::DijetsAccount;

fun main() {
    let carol_prev_balance = DijetsAccount::balance<XUS>(@{{carol}});
    let alice_prev_balance = DijetsAccount::balance<XUS>(@{{alice}});
    AlicePays::pay(@{{carol}}, 10);
    assert(carol_prev_balance + 10 == DijetsAccount::balance<XUS>(@{{carol}}), 0);
    assert(alice_prev_balance - 10 == DijetsAccount::balance<XUS>(@{{alice}}), 1);
}
}
// check: "Keep(EXECUTED)"
