// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

// Note: If this test file fails to run, it is possible that the
// compiled version of the Move stdlib needs to be updated. This code
// is compiled with the latest compiler and stdlib, but it runs with
// the compiled stdlib.

address {{sender}} {

module MyModule {
    use DijetsFramework::Dijets::Dijets;

    // The identity function for coins: takes a Dijets<T> as input and hands it back
    public fun id<T>(c: Dijets<T>): Dijets<T> {
        c
    }
}

}
