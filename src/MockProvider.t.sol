// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import {MockProvider} from "./MockProvider.sol";

contract MockProviderTest is DSTest {
    MockProvider internal mockProvider;

    function setUp() public {
        mockProvider = new MockProvider();
    }

    function test_DefaultCalldata_Returns_SetResponse(bytes memory query)
        public
    {
        bytes memory response = "0x1234";
        mockProvider.setDefaultResponse(
            MockProvider.ReturnData({success: true, data: response})
        );

        // solhint-disable-next-line
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(abi.encode(query));

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response),
            keccak256(responseReceived),
            "Returned response should match set default"
        );

        emit log_bytes(responseReceived);
    }

    function test_SetResponse_For_Query() public {
        bytes memory query = hex"1234";
        bytes memory response = hex"5678";
        mockProvider.givenQueryReturnResponse(
            query,
            MockProvider.ReturnData({success: true, data: response}),
            false
        );

        // solhint-disable-next-line
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response),
            keccak256(responseReceived),
            "Returned response should match"
        );

        emit log_bytes(response);
        emit log_bytes(responseReceived);
    }

    function test_SetResponse_For_Selector(bytes memory params) public {
        bytes4 selector = bytes4(0x72aa1899);
        bytes memory response = hex"5678";
        mockProvider.givenSelectorReturnResponse(
            selector,
            MockProvider.ReturnData({success: true, data: response}),
            false
        );

        bytes memory query = abi.encodePacked(selector, params);

        // solhint-disable-next-line
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response),
            keccak256(responseReceived),
            "Returned response should match"
        );

        emit log_bytes(response);
        emit log_bytes(responseReceived);
    }

    function test_SetResponse_ToFail_ForQuery() public {
        bytes memory query = hex"1234";
        mockProvider.givenQueryReturnResponse(
            query,
            MockProvider.ReturnData({success: false, data: hex""}),
            false
        );

        // solhint-disable-next-line
        (bool okReceived, ) = address(mockProvider).call(query);

        assertTrue(okReceived == false, "Should fail doing a call");
    }
}
