// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {MockProvider} from "./MockProvider.sol";

// solhint-disable func-name-mixedcase
contract MockProviderTest is Test {
    MockProvider internal mockProvider;

    function setUp() public {
        mockProvider = new MockProvider();
    }

    function test_getCallData_Returns_CorrectData() public {
        bytes memory query = hex"1122334455667788";
        uint256 queryValue = 1;

        // solhint-disable-next-line avoid-low-level-calls
        address(mockProvider).call{value: queryValue}(query);

        MockProvider.CallData memory rd = mockProvider.getCallData(0);

        assertEq(rd.caller, address(this), "Should match caller");
        assertEq(
            rd.functionSelector,
            bytes4(query),
            "Should match function signature"
        );
        assertEq(keccak256(rd.data), keccak256(query), "Should match query");
        assertEq(rd.value, queryValue, "Should match ether amount");
    }

    function testFail_getCallData_Fails_WhenIndexIsOutOfBounds() public view {
        mockProvider.getCallData(0);
    }

    function test_setDefaultResponse_Enables_ReturnResponseOnQuery(
        bytes memory response_
    ) public {
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
            "Should match set default"
        );
    }

    function test_setDefault_Enables_ReturnResponseOnQuery(
        bytes memory response_
    ) public {
        bytes memory query = hex"11223344";

        mockProvider.setDefault(response_);

        // solhint-disable-next-line avoid-low-level-calls
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response_),
            keccak256(responseReceived),
            "Should match set default"
        );
    }

    function test_givenQueryReturnResponse_Enables_ReturnResponseOnQuery(
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
    }

    function test_givenQueryReturn_Enables_ReturnResponseOnQuery(
        bytes memory response_
    ) public {
        bytes memory query = hex"11223344";

        mockProvider.givenQueryReturn(query, response_);

        // solhint-disable-next-line avoid-low-level-calls
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call(query);

        assertTrue(okReceived, "Should not fail doing a call");
        assertEq(
            keccak256(response_),
            keccak256(responseReceived),
            "Returned response should match"
        );
    }

    function test_givenSelectorReturnResponse_Enables_ReturnResponseOnQuery(
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
    }

    function test_givenSelectorReturn_Enables_ReturnResponseOnQuery(
        bytes memory params_,
        bytes memory response_
    ) public {
        bytes4 selector = hex"11223344";
        mockProvider.givenSelectorReturn(selector, response_);

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

    function test_givenSelectorConsumeGas_Consumes_AllGas(bytes memory params_)
        public
    {
        bytes4 selector = hex"11223344";
        mockProvider.givenSelectorConsumeGas(selector);

        bytes memory query = abi.encodePacked(selector, params_);

        uint256 initialGas = gasleft();
        uint256 forwardGas = 100000;

        // This call has to consume all the provided gas
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call{gas: forwardGas}(query);

        // Check that all sent gas was consumed as per definition below
        // remainingGas + forwardGas + c = initialGas
        //
        // initialGas - how much gas we started with before the call
        // remainingGas - how much gas we have right now
        // c - how much gas was consumed to set up the call and return;
        //     this is difficult to hardcode or calculate, so we just
        //     change the equality to be a bit more relaxed:
        // remainingGas + forwardGas < initialGas
        assertLt(gasleft() + forwardGas, initialGas, "Gas should be consumed");

        assertFalse(okReceived, "Should fail when gas is consumed");
        assertEq(
            keccak256(responseReceived),
            keccak256(bytes("")),
            "Should not return a message"
        );
    }

    function test_givenQueryConsumeGas_Consumes_AllGas() public {
        bytes memory query = hex"1122334455667788";
        mockProvider.givenQueryConsumeGas(query);

        uint256 initialGas = gasleft();
        uint256 forwardGas = 100000;

        // This call has to consume all the provided gas
        (bool okReceived, bytes memory responseReceived) = address(mockProvider)
            .call{gas: forwardGas}(query);

        // Check that all sent gas was consumed
        assertLt(gasleft() + forwardGas, initialGas, "Gas should be consumed");

        assertFalse(okReceived, "Should fail when gas is consumed");
        assertEq(
            keccak256(responseReceived),
            keccak256(bytes("")),
            "Should not return a message"
        );
    }

    function test_enableLogging_LogsRequests() public {
        bytes memory query = hex"11223344";
        uint256 queryValue = 1;

        // Enable arbitrary logging
        mockProvider.enableLogging();

        // solhint-disable-next-line avoid-low-level-calls
        address(mockProvider).call{value: queryValue}(query);

        // Get logged query
        MockProvider.CallData memory cd = mockProvider.getCallData(0);

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
        assertEq(cd.value, queryValue, "Logged message value should match");
    }

    function testFail_disableLogging_DisablesLogging() public {
        // Disable logging
        mockProvider.disableLogging();

        // Define arbitrary query
        bytes memory query = hex"11223344";
        uint256 queryValue = 1;

        // solhint-disable-next-line avoid-low-level-calls
        address(mockProvider).call{value: queryValue}(query);

        // Get logged query should fail since logging is disabled and index 0 is out of bounds
        mockProvider.getCallData(0);
    }
}
