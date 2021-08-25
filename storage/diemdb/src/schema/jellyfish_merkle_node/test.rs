// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use super::*;
use dijets_crypto::HashValue;
use dijets_jellyfish_merkle::node_type::Node;
use dijets_types::account_state_blob::AccountStateBlob;
use proptest::prelude::*;
use schemadb::schema::assert_encode_decode;

proptest! {
    #[test]
    fn test_jellyfish_merkle_node_schema(
        node_key in any::<NodeKey>(),
        account_key in any::<HashValue>(),
        blob in any::<AccountStateBlob>(),
    ) {
        assert_encode_decode::<JellyfishMerkleNodeSchema>(
            &node_key,
            &Node::new_leaf(account_key, blob),
        );
    }
}
