#!/bin/sh
# Copyright (c) The Dijets Core Contributors
# SPDX-License-Identifier: Apache-2.0

DIJETS="$(git rev-parse --show-toplevel)"
FRAMEWORK="$DIJETSlanguage/dijets-framework/modules"
STDLIB="$DIJETSlanguage/move-stdlib/modules"

for config in *.toml ; do
  # Benchmark per function
  cargo run -q --release -p prover-lab -- \
    bench -f -c $config -d $STDLIB -d $FRAMEWORK $FRAMEWORK/*.move
  # Benchmark per module
  cargo run -q --release -p prover-lab -- \
    bench -c $config -d $STDLIB -d $FRAMEWORK $FRAMEWORK/*.move
done
