//! account: bob, 0, 0, address

//! sender: blessed
script {
    use DijetsFramework::XUS::XUS;
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::VASPDomain;

    fun main(account: signer) {
        let tc_account = &account;
        let addr: address = @{{bob}};
        assert(!DijetsAccount::exists_at(addr), 83);
        DijetsAccount::create_parent_vasp_account<XUS>(tc_account, addr, {{bob::auth_key}}, x"aa", false);
        assert(VASPDomain::tc_domain_manager_exists(), 77);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script{
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::VASPDomain;

    fun main(tc_account: signer) {
        let addr: address = @{{bob}};
        assert(DijetsAccount::exists_at(addr), 455);
        let tc_account = &tc_account;
        let domain_name = b"dijets";

        /// add a dijets id domain
        VASPDomain::add_vasp_domain(tc_account, addr, copy domain_name);

        /// check if dijets id domain is added to VASPDomains
        assert(VASPDomain::has_vasp_domain(addr, domain_name), 5);
    }
}
// check: VASPDomainEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script{
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::VASPDomain;

    fun main(tc_account: signer) {
        let addr: address = @{{bob}};
        assert(DijetsAccount::exists_at(addr), 455);
        let tc_account = &tc_account;
        let domain_name = b"dijets";

        /// add the same dijets ID domain to the bob account, expect it to fail
        VASPDomain::add_vasp_domain(tc_account, addr, copy domain_name);

        /// check if the previously added domain is still there
        assert(VASPDomain::has_vasp_domain(addr, domain_name), 389);
    }
}
// check: "Keep(ABORTED { code: 775,"

//! new-transaction
//! sender: blessed
script{
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::VASPDomain;

    fun main(tc_account: signer) {
        let addr: address = @{{bob}};
        assert(DijetsAccount::exists_at(addr), 2);
        let tc_account = &tc_account;
        let domain_name = b"dijets";

        /// remove a dijets id domain
        VASPDomain::remove_vasp_domain(tc_account, addr, copy domain_name);

        /// check if dijets id domain is removed from VASPDomains
        assert(!VASPDomain::has_vasp_domain(addr, domain_name), 205);
    }
}
// check: VASPDomainEvent
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script{
    use DijetsFramework::DijetsAccount;
    use DijetsFramework::VASPDomain;

    fun main(tc_account: signer) {
        let addr: address = @{{bob}};
        assert(DijetsAccount::exists_at(addr), 455);
        let tc_account = &tc_account;
        let domain_name = b"aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggg";

        /// Try adding a domain ID longer than 63 characters, expect to fail
        VASPDomain::add_vasp_domain(tc_account, addr, copy domain_name);

        /// check that dijets id domain is not added to VASPDomains
        assert(!VASPDomain::has_vasp_domain(addr, domain_name), 888);
    }
}
// check: "Keep(ABORTED { code: 1287,"

//! new-transaction
//! sender: bob
script{
    use DijetsFramework::VASPDomain;

    fun main(account: signer) {
        /// check if vasp account tries to add domain id, it fails
        let account = &account;
        let addr: address = @{{bob}};
        VASPDomain::add_vasp_domain(account, addr, b"dijets");
    }
}
// check: "Keep(ABORTED { code: 258,"
