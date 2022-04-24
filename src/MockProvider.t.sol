// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import {MockProvider} from "./MockProvider.sol";

// solhint-disable func-name-mixedcase
contract MockProviderTest is DSTest {
    MockProvider internal mockProvider;

    function setUp() public {
        mockProvider = new MockProvider();
    }

    function test_setDefaultResponse_Returns_Response(bytes memory response_)
        public
    {
        bytes memory query = hex"11223344";

        mockProvider.setDefaultResponse(
            MockProvider.ReturnData({success: true, data: response_})
        );

        // solhint-disable-next-line avoid-low-level-calls
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(abi.encode(query));

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response_),
            keccak256(responseReceived),
            "Returned response should match set default"
        );

        // In case the test fails, print the response to aid debugging
        emit log_bytes(response_);
        emit log_bytes(responseReceived);
    }

    function test_givenQueryReturnResponse_Returns_Response(
        bytes memory response_
    ) public {
        bytes memory query = hex"11223344";

        mockProvider.givenQueryReturnResponse(
            query,
            MockProvider.ReturnData({success: true, data: response_}),
            false
        );

        // solhint-disable-next-line avoid-low-level-calls
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response_),
            keccak256(responseReceived),
            "Returned response should match"
        );

        // In case the test fails, print the response to aid debugging
        emit log_bytes(response_);
        emit log_bytes(responseReceived);
    }

    function test_givenQueryReturn_Returns_Response(bytes memory response_)
        public
    {
        // Forward call
        test_givenQueryReturnResponse_Returns_Response(response_);
    }

    function test_givenSelectorReturnResponse_Returns_Response(
        bytes memory params_,
        bytes memory response_
    ) public {
        bytes4 selector = hex"11223344";
        mockProvider.givenSelectorReturnResponse(
            selector,
            MockProvider.ReturnData({success: true, data: response_}),
            false
        );

        bytes memory query = abi.encodePacked(selector, params_);

        // solhint-disable-next-line avoid-low-level-calls
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response_),
            keccak256(responseReceived),
            "Returned response should match"
        );

        // In case the test fails, print the response to aid debugging
        emit log_bytes(response_);
        emit log_bytes(responseReceived);
    }

    function test_givenSelectorReturn_Returns_Response(
        bytes memory params_,
        bytes memory response_
    ) public {
        // Forward call
        test_givenSelectorReturnResponse_Returns_Response(params_, response_);
    }

    function test_givenQueryReturnResponse_Fails_WithErrorMessage() public {
        bytes memory query = hex"11223344";
        bytes memory reason = bytes("This is the error message");
        mockProvider.givenQueryReturnResponse(
            query,
            MockProvider.ReturnData({success: false, data: reason}),
            false
        );

        // solhint-disable-next-line avoid-low-level-calls
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        bytes memory reasonBytes = bytes.concat(
            // bytes4(keccak256("Error(string)"))
            hex"08c379a0",
            // encoded string reason
            abi.encode(reason)
        );
        bytes32 reasonHash = keccak256(reasonBytes);
        bytes32 responseReceivedHash = keccak256(responseReceived);

        assertTrue(okReceived == false, "Should fail doing a call");
        assertEq(
            responseReceivedHash,
            reasonHash,
            "Error message should match"
        );

        // In case the test fails, print the response to aid debugging
        emit logs(reasonBytes);
        emit logs(responseReceived);
    }

    function test_givenQueryReturnResponse_Logs_Query(bytes memory response_)
        public
    {
        bytes memory query = hex"1122334455667788";

        mockProvider.givenQueryReturnResponse(
            query,
            MockProvider.ReturnData({success: true, data: response_}),
            true
        );

        // solhint-disable-next-line avoid-low-level-calls
        address(mockProvider).call(query);

        // Get logged query
        MockProvider.CallData memory cd = mockProvider.getCallData(0);

        // Check logged query
        assertEq(cd.caller, address(this), "Logged caller should match");
        assertEq(
            cd.functionSelector,
            bytes4(query),
            "Logged query should match"
        );
        assertEq(
            keccak256(cd.data),
            keccak256(query),
            "Logged query should match"
        );
        assertEq(cd.value, 0, "Logged message value should match");
    }
}
