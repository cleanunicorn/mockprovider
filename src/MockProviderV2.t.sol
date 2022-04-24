// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import {MockProviderV2} from "./MockProviderV2.sol";

contract MockProviderV2Test is DSTest {
    MockProviderV2 internal mockProvider;

    function setUp() public {
        mockProvider = new MockProviderV2();
    }

    function test_givenQueryReturn_Returns_SetResponse() public {
        bytes memory query = hex"11223344";
        bytes memory response = hex"55667788";

        mockProvider.givenQueryReturn(query, response);

        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertEq(
            keccak256(response),
            keccak256(responseReceived),
            "Returned response should match"
        );

        emit log_bytes(response);
        emit log_bytes(responseReceived);
    }
}
