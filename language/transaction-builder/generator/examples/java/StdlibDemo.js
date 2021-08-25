// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

import java.util.Arrays;
import java.util.ArrayList;

import com.novi.serde.Bytes;
import com.novi.serde.Unsigned; // used as documentation.
import com.dijets.stdlib.Helpers;
import com.dijets.stdlib.ScriptCall;;
import com.dijets.stdlib.ScriptFunctionCall;;
import com.dijets.types.AccountAddress;
import com.dijets.types.Identifier;
import com.dijets.types.Script;
import com.dijets.types.StructTag;
import com.dijets.types.TypeTag;
import com.dijets.types.TransactionPayload;

public class StdlibDemo {
    private static void demo_p2p_script() throws Exception {
        StructTag.Builder builder = new StructTag.Builder();
        builder.address = AccountAddress.valueOf(new byte[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1});
        builder.module = new Identifier("XDX");
        builder.name = new Identifier("XDX");
        builder.type_params = new ArrayList<com.dijets.types.TypeTag>();
        StructTag tag = builder.build();

        TypeTag token = new TypeTag.Struct(tag);

        AccountAddress payee = AccountAddress.valueOf(
            new byte[]{0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22});

        @Unsigned Long amount = Long.valueOf(1234567);
        Script script =
            Helpers.encode_peer_to_peer_with_metadata_script(token, payee, amount, Bytes.empty(), Bytes.empty());

        ScriptCall.PeerToPeerWithMetadata call = (ScriptCall.PeerToPeerWithMetadata)Helpers.decode_script(script);
        assert(call.amount.equals(amount));
        assert(call.payee.equals(payee));

        byte[] output = script.bcsSerialize();
        for (byte o : output) {
            System.out.print(((int) o & 0xFF) + " ");
        };
        System.out.println();
    }

    private static void demo_p2p_script_function() throws Exception {
        StructTag.Builder builder = new StructTag.Builder();
        builder.address = AccountAddress.valueOf(new byte[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1});
        builder.module = new Identifier("XDX");
        builder.name = new Identifier("XDX");
        builder.type_params = new ArrayList<com.dijets.types.TypeTag>();
        StructTag tag = builder.build();

        TypeTag token = new TypeTag.Struct(tag);

        AccountAddress payee = AccountAddress.valueOf(
            new byte[]{0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22});

        @Unsigned Long amount = Long.valueOf(1234567);
        TransactionPayload payload =
            Helpers.encode_peer_to_peer_with_metadata_script_function(token, payee, amount, Bytes.empty(), Bytes.empty());

        ScriptFunctionCall.PeerToPeerWithMetadata call = (ScriptFunctionCall.PeerToPeerWithMetadata)Helpers.decode_script_function_payload(payload);
        assert(call.amount.equals(amount));
        assert(call.payee.equals(payee));

        byte[] output = payload.bcsSerialize();
        for (byte o : output) {
            System.out.print(((int) o & 0xFF) + " ");
        };
        System.out.println();
    }

    public static void main(String[] args) throws Exception {
        demo_p2p_script();
        demo_p2p_script_function();
    }
}
