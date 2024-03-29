// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

/// @title Mocking contract for testing
/// @notice You can use this contract to mock functionality in your tests
/// @dev All function calls are currently implemented without side effects
contract MockProvider is Test {
    /// @notice Emitted when an out of bounds calldata is received
    error MockProvider__getCallData_indexOutOfBounds(uint256 index);

    /// @notice Structure that logs calls to the provider
    struct CallData {
        // Who made the call
        address caller;
        // What function was called
        bytes4 functionSelector;
        // Contains called function and arguments
        bytes data;
        // How much ether was sent in the call
        uint256 value;
    }

    /// @notice State variable that contains logged calls to the provider
    CallData[] internal _callData;

    /// @notice Structure that defines the return data for a given call
    struct ReturnData {
        // Whether the call should be successful
        bool success;
        // The data to return
        // If the call is unsuccessful, this is the reason for failure
        bytes data;
    }

    /// @dev Define fallback response for all calls.
    ReturnData internal _defaultReturnData;

    /// @notice Contains the mapping from the expected query to the return data
    /// @dev keccak256(query) => ReturnData
    mapping(bytes32 => ReturnData) internal _givenQueryReturn;

    /// @notice Whether a query was set to return something
    /// @dev keccak256(query) => bool
    mapping(bytes32 => bool) internal _givenQuerySet;

    /// @notice Whether arbitrary queries should be logged
    /// @dev starts as enabled
    bool public loggingEnabled = true;

    /// @notice Whether the query should be logged
    /// @dev keccak256(query) => bool
    mapping(bytes32 => bool) internal _givenQueryLog;

    /// @notice Whether the query should consume all gas
    /// @dev keccak256(query) => bool
    mapping(bytes32 => bool) internal _givenQueryConsumeAllGas;

    /// @notice Returns the logged call data for a given index
    /// @dev If the provided index is out of bounds, it reverts
    /// @param index_ The index of the call data to return
    /// @return CallData structure containing the logged call data
    function getCallData(uint256 index_) public view returns (CallData memory) {
        if (index_ >= _callData.length) {
            revert MockProvider__getCallData_indexOutOfBounds(index_);
        }
        return _callData[index_];
    }

    /// @notice Disables logging of arbitrary queries
    /// @dev Any query that isn't explicitly set, will not be logged
    function disableLogging() public {
        loggingEnabled = false;
    }

    /// @notice Enables logging of arbitrary queries
    /// @dev Any query that isn't explicitly set, will be logged
    function enableLogging() public {
        loggingEnabled = true;
    }

    /// @notice Defines the default return in case no query matches
    /// @param returnData_ The return data to return
    function setDefaultResponse(ReturnData memory returnData_) public {
        _defaultReturnData = returnData_;
    }

    /// @notice Defines the default return in case no query matches
    /// @param response_ The return data to return
    function setDefault(bytes memory response_) external {
        // Forward execution
        setDefaultResponse(ReturnData({success: true, data: response_}));
    }

    /// @notice Defines the return data for a given query
    /// @param query_ The query to match
    /// @param returnData_ The return data to return
    /// @param log_ Whether the query should be logged
    function givenQueryReturnResponse(
        bytes memory query_,
        ReturnData memory returnData_,
        bool log_
    ) public {
        // Calculate the query key
        bytes32 queryKey = keccak256(query_);

        // Save the return data for this query
        _givenQueryReturn[queryKey] = returnData_;

        // Mark the query as set
        _givenQuerySet[queryKey] = true;

        // Save whether the query should be logged
        _givenQueryLog[queryKey] = log_;
    }

    /// @notice Defines the return data for a given query
    /// @dev Does not log the query
    /// @param query_ The query to match
    /// @param response_ The return data to return
    function givenQueryReturn(bytes memory query_, bytes memory response_)
        public
    {
        // Forward execution
        givenQueryReturnResponse(
            query_,
            ReturnData({success: true, data: response_}),
            false
        );
    }

    /// @notice Defines the return data for a given selector (msg.sig)
    /// @param selector_ The `msg.data` function selector to match
    /// @param returnData_ The return data to return
    /// @param log_ Whether the query should be logged
    function givenSelectorReturnResponse(
        bytes4 selector_,
        ReturnData memory returnData_,
        bool log_
    ) public {
        // Calculate the key based on the provided selector
        bytes32 queryKey = keccak256(abi.encode(selector_));

        // Save the return data for this query
        _givenQueryReturn[queryKey] = returnData_;

        // Mark the query as set
        _givenQuerySet[queryKey] = true;

        // Save whether the query should be logged
        _givenQueryLog[queryKey] = log_;
    }

    /// @notice Defines the return data for a given selector (msg.sig)
    /// @param selector_ The `msg.data` function selector to match
    /// @param response_ The return data to return
    function givenSelectorReturn(bytes4 selector_, bytes memory response_)
        public
    {
        // Forward call
        givenSelectorReturnResponse(
            selector_,
            ReturnData({success: true, data: response_}),
            false
        );
    }

    function givenSelectorExecuteConsumeGas(
        bytes4 selector_,
        ReturnData memory returnData_,
        bool log_
    ) public {
        // Calculate the key based on the provided selector
        bytes32 queryKey = keccak256(abi.encode(selector_));

        // Save the return data for this query
        _givenQueryReturn[queryKey] = returnData_;

        // Mark the query as set
        _givenQuerySet[queryKey] = true;

        // Save whether the query should be logged
        _givenQueryLog[queryKey] = log_;

        // Consume all gas
        _givenQueryConsumeAllGas[queryKey] = true;
    }

    function givenQueryExecuteConsumeGas(
        bytes memory query_,
        ReturnData memory returnData_,
        bool log_
    ) internal {
        // Calculate the key based on the provided selector
        bytes32 queryKey = keccak256(query_);

        // Save the return data for this query
        _givenQueryReturn[queryKey] = returnData_;

        // Mark the query as set
        _givenQuerySet[queryKey] = true;

        // Save whether the query should be logged
        _givenQueryLog[queryKey] = log_;

        // Consume all gas
        _givenQueryConsumeAllGas[queryKey] = true;
    }

    function givenSelectorConsumeGas(bytes4 selector_) public {
        // Forward call
        givenSelectorExecuteConsumeGas(
            selector_,
            ReturnData({success: false, data: bytes("")}),
            false
        );
    }

    function givenQueryConsumeGas(bytes memory query_) public {
        // Forward call
        givenQueryExecuteConsumeGas(
            query_,
            ReturnData({success: false, data: bytes("")}),
            false
        );
    }

    /// @notice Handles the calls
    /// @dev Tries to match calls based on `msg.data` or `msg.sig` and returns the corresponding return data
    // prettier-ignore
    fallback(bytes calldata) external payable returns (bytes memory){
        bytes32 queryKey = keccak256(msg.data);
        bytes32 selectorKey = keccak256(abi.encode(msg.sig));
        // Check if any set query matches the current query
        if (_givenQuerySet[queryKey] || _givenQuerySet[selectorKey]) {
            bytes32 key = _givenQuerySet[queryKey] ? queryKey : selectorKey;

            // Log call
            if (_givenQueryLog[key]) {
                _logCall();
            }

            // Check if the query should consume all gas
            if (
                _givenQueryConsumeAllGas[key]
            ) {
                emit log_string("Should consume all the gas");
                _consumeGas();
            } 

            // Return data as specified by the query
            ReturnData memory returnData = _givenQueryReturn[key];
            require(returnData.success, string(returnData.data));
            return returnData.data;
        } 

        // Log the call
        if (loggingEnabled) {
            _logCall();
        }

        // Default to sending the default response
        return _defaultReturnData.data;
    }

    /// @notice Logs the call if logging is enabled or a default response is matched
    function _logCall() internal {
        // Log query
        _callData.push(
            CallData({
                caller: msg.sender,
                functionSelector: msg.sig,
                data: msg.data,
                value: msg.value
            })
        );
    }

    /// @dev Taken from
    /// https://github.com/gnosis/mock-contract/blob/b0f735ddc62d5000b50667011d69142a4dee9c71/contracts/MockContract.sol#L300-L308
    function _consumeGas() internal {
        while (true) {
            bool s;
            assembly {
                // expensive call to EC multiply contract
                s := call(sub(gas(), 2000), 6, 0, 0x0, 0xc0, 0x0, 0x60)
            }
        }
    }
}
