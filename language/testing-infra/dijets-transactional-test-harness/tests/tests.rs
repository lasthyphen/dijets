// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use dijets_transactional_test_harness::run_test;

datatest_stable::harness!(run_test, "tests", r".*\.(mvir|move)$");
