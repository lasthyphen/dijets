//! account: bob, 10000XDX
//! account: alice, 0XDX
//! account: abby, 0, 0, address
//! account: doris, 0XUS, 0

module {{default}}::Holder {
    use Std::Signer;

    struct Hold<T> has key {
        x: T
    }

    public fun hold<T: store>(account: &signer, x: T) {
        move_to(account, Hold<T>{x})
    }

    public fun get<T: store>(account: &signer): T
    acquires Hold {
        let Hold {x} = move_from<Hold<T>>(Signer::address_of(account));
        x
    }
}

//! new-transaction
script {
    use DijetsFramework::DijetsAccount;
    fun main(sender: signer) {
        let sender = &sender;
        DijetsAccount::initialize(sender, x"00000000000000000000000000000000");
    }
}
// check: "Keep(ABORTED { code: 1,"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::XDX::XDX;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
        let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XDX>(&with_cap, @{{bob}}, 10, x"", x"");
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::XDX::XDX;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XDX>(&with_cap, @{{abby}}, 10, x"", x"");
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 4357,"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XUS>(&with_cap, @{{abby}}, 10, x"", x"");
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 4869,"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::XDX::XDX;
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XDX>(&with_cap, @{{doris}}, 10, x"", x"");
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 4615,"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::DijetsAccount;
    fun main(account: signer) {
    let account = &account;
        let rot_cap = DijetsAccount::extract_key_rotation_capability(account);
        DijetsAccount::rotate_authentication_key(&rot_cap, x"123abc");
        DijetsAccount::restore_key_rotation_capability(rot_cap);
    }
}
// check: "Keep(ABORTED { code: 2055,"

//! new-transaction
script {
    use DijetsFramework::DijetsAccount;
    use {{default}}::Holder;
    fun main(account: signer) {
    let account = &account;
        Holder::hold(
            account,
            DijetsAccount::extract_key_rotation_capability(account)
        );
        Holder::hold(
            account,
            DijetsAccount::extract_key_rotation_capability(account)
        );
    }
}
// check: "Keep(ABORTED { code: 2305,"

//! new-transaction
script {
    use DijetsFramework::DijetsAccount;
    use Std::Signer;
    fun main(sender: signer) {
    let sender = &sender;
        let cap = DijetsAccount::extract_key_rotation_capability(sender);
        assert(
            *DijetsAccount::key_rotation_capability_address(&cap) == Signer::address_of(sender), 0
        );
        DijetsAccount::restore_key_rotation_capability(cap);
        let with_cap = DijetsAccount::extract_withdraw_capability(sender);

        assert(
            *DijetsAccount::withdraw_capability_address(&with_cap) == Signer::address_of(sender),
            0
        );
        DijetsAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::XDX::XDX;
    fun main(account: signer) {
    let account = &account;
        let with_cap = DijetsAccount::extract_withdraw_capability(account);
        DijetsAccount::pay_from<XDX>(&with_cap, @{{alice}}, 10000, x"", x"");
        DijetsAccount::restore_withdraw_capability(with_cap);
        assert(DijetsAccount::balance<XDX>(@{{alice}}) == 10000, 60)
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
//! type-args: 0x1::XUS::XUS
//! args: 0, 0x0, {{bob::auth_key}}, b"bob", true
stdlib_script::AccountCreationScripts::create_parent_vasp_account
// check: "Keep(ABORTED { code: 2567,"

//! new-transaction
//! sender: blessed
//! type-args: 0x1::XUS::XUS
//! args: 0, {{abby}}, x"", b"bob", true
stdlib_script::AccountCreationScripts::create_parent_vasp_account
// check: "Keep(ABORTED { code: 2055,"

//! new-transaction
script {
use DijetsFramework::DijetsAccount;
fun main() {
    DijetsAccount::sequence_number(@0x1);
}
}
// check: "Keep(ABORTED { code: 5,"

//! new-transaction
script {
use DijetsFramework::DijetsAccount;
fun main() {
    DijetsAccount::authentication_key(@0x1);
}
}
// check: "Keep(ABORTED { code: 5,"

//! new-transaction
script {
use DijetsFramework::DijetsAccount;
fun main() {
    DijetsAccount::delegated_key_rotation_capability(@0x1);
}
}
// check: "Keep(ABORTED { code: 5,"

//! new-transaction
script {
use DijetsFramework::DijetsAccount;
fun main() {
    DijetsAccount::delegated_withdraw_capability(@0x1);
}
}
// check: "Keep(ABORTED { code: 5,"
