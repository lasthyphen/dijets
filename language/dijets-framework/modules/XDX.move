/// NB: This module is a stub of the `XDX` at the moment.
///
/// Once the component makeup of the XDX has been chosen the
/// `Reserve` will be updated to hold the backing coins in the correct ratios.

module DijetsFramework::XDX {
    use DijetsFramework::AccountLimits;
    use DijetsFramework::CoreAddresses;
    use Std::Errors;
    use Std::FixedPoint32;
    use DijetsFramework::Dijets;
    use DijetsFramework::DijetsTimestamp;

    /// The type tag representing the `XDX` currency on-chain.
    struct XDX { }

    /// Note: Currently only holds the mint, burn, and preburn capabilities for
    /// XDX. Once the makeup of the XDX has been determined this resource will
    /// be updated to hold the backing XDX reserve compnents on-chain.
    ///
    /// The on-chain reserve for the `XDX` holds both the capability for minting `XDX`
    /// coins, and also each reserve component that holds the backing for these coins on-chain.
    /// Currently this holds no coins since XDX is not able to be minted/created.
    struct Reserve has key {
        /// The mint capability allowing minting of `XDX` coins.
        mint_cap: Dijets::MintCapability<XDX>,
        /// The burn capability for `XDX` coins. This is used for the unpacking
        /// of `XDX` coins into the underlying backing currencies.
        burn_cap: Dijets::BurnCapability<XDX>,
        /// The preburn for `XDX`. This is an administrative field since we
        /// need to alway preburn before we burn.
        preburn_cap: Dijets::Preburn<XDX>,
        // TODO: Once the reserve has been determined this resource will
        // contain a ReserveComponent<Currency> for every currency that makes
        // up the reserve.
    }

    /// The `Reserve` resource is in an invalid state
    const ERESERVE: u64 = 0;

    /// Initializes the `XDX` module. This sets up the initial `XDX` ratios and
    /// reserve components, and creates the mint, preburn, and burn
    /// capabilities for `XDX` coins. The `XDX` currency must not already be
    /// registered in order for this to succeed. The sender must both be the
    /// correct address (`@CurrencyInfo`) and have the
    /// correct permissions (`&Capability<RegisterNewCurrency>`). Both of these
    /// restrictions are enforced in the `Dijets::register_currency` function, but also enforced here.
    public fun initialize(
        dr_account: &signer,
        tc_account: &signer,
    ) {
        DijetsTimestamp::assert_genesis();
        // Operational constraint
        CoreAddresses::assert_currency_info(dr_account);
        // Reserve must not exist.
        assert(!exists<Reserve>(@DijetsRoot), Errors::already_published(ERESERVE));
        let (mint_cap, burn_cap) = Dijets::register_currency<XDX>(
            dr_account,
            FixedPoint32::create_from_rational(1, 1), // exchange rate to XDX
            true,    // is_synthetic
            1000000, // scaling_factor = 10^6
            1000,    // fractional_part = 10^3
            b"XDX"
        );
        // XDX cannot be minted.
        Dijets::update_minting_ability<XDX>(tc_account, false);
        AccountLimits::publish_unrestricted_limits<XDX>(dr_account);
        let preburn_cap = Dijets::create_preburn<XDX>(tc_account);
        move_to(dr_account, Reserve { mint_cap, burn_cap, preburn_cap });
    }
    spec initialize {
       use DijetsFramework::Roles;
        include CoreAddresses::AbortsIfNotCurrencyInfo{account: dr_account};
        aborts_if exists<Reserve>(@DijetsRoot) with Errors::ALREADY_PUBLISHED;
        include Dijets::RegisterCurrencyAbortsIf<XDX>{
            currency_code: b"XDX",
            scaling_factor: 1000000
        };
        include AccountLimits::PublishUnrestrictedLimitsAbortsIf<XDX>{publish_account: dr_account};

        include Dijets::RegisterCurrencyEnsures<XDX>;
        include Dijets::UpdateMintingAbilityEnsures<XDX>{can_mint: false};
        include AccountLimits::PublishUnrestrictedLimitsEnsures<XDX>{publish_account: dr_account};
        ensures exists<Reserve>(@DijetsRoot);

        /// Registering XDX can only be done in genesis.
        include DijetsTimestamp::AbortsIfNotGenesis;
        /// Only the DijetsRoot account can register a new currency [[H8]][PERMISSION].
        include Roles::AbortsIfNotDijetsRoot{account: dr_account};
        /// Only the TreasuryCompliance role can update the `can_mint` field of CurrencyInfo [[H2]][PERMISSION].
        /// Moreover, only the TreasuryCompliance role can create Preburn.
        include Roles::AbortsIfNotTreasuryCompliance{account: tc_account};
    }

    /// Returns true if `CoinType` is `XDX::XDX`
    public fun is_xdx<CoinType>(): bool {
        Dijets::is_currency<CoinType>() &&
            Dijets::currency_code<CoinType>() == Dijets::currency_code<XDX>()
    }
    spec is_xdx {
        pragma opaque;
        include Dijets::spec_is_currency<CoinType>() ==> Dijets::AbortsIfNoCurrency<XDX>;
        ensures result == spec_is_xdx<CoinType>();
    }
    spec fun spec_is_xdx<CoinType>(): bool {
        Dijets::spec_is_currency<CoinType>() && Dijets::spec_is_currency<XDX>() &&
            (Dijets::spec_currency_code<CoinType>() == Dijets::spec_currency_code<XDX>())
    }

    /// Return the account address where the globally unique XDX::Reserve resource is stored
    public fun reserve_address(): address {
        @CurrencyInfo
    }

    // =================================================================
    // Module Specification

    spec module {} // switch documentation context back to module level

    /// # Persistence of Resources

    spec module {
        /// After genesis, the Reserve resource exists.
        invariant DijetsTimestamp::is_operating() ==> reserve_exists();

        /// After genesis, XDX is registered.
        invariant DijetsTimestamp::is_operating() ==> Dijets::is_currency<XDX>();
    }

    /// # Helper Functions
    spec module {
        /// Checks whether the Reserve resource exists.
        fun reserve_exists(): bool {
           exists<Reserve>(@CurrencyInfo)
        }

        /// After genesis, `LimitsDefinition<XDX>` is published at Dijets root. It's published by
        /// AccountLimits::publish_unrestricted_limits, but we can't prove the condition there because
        /// it does not hold for all types (but does hold for XDX).
        invariant DijetsTimestamp::is_operating()
            ==> exists<AccountLimits::LimitsDefinition<XDX>>(@DijetsRoot);

        /// `LimitsDefinition<XDX>` is not published at any other address
        invariant forall addr: address where exists<AccountLimits::LimitsDefinition<XDX>>(addr):
            addr == @DijetsRoot;

        /// `Reserve` is persistent
        invariant update old(exists<Reserve>(reserve_address()))
            ==> exists<Reserve>(reserve_address());
    }

}
