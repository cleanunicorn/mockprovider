// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract MockProvider {
    struct CallData {
        address caller;
        bytes4 functionSelector;
        bytes data;
        uint256 value;
    }

    CallData[] internal callData;

    function getCallData(uint256 index_) public view returns (CallData memory) {
        if (index_ >= callData.length) {
            return
                CallData({
                    caller: address(0),
                    functionSelector: bytes4(0),
                    data: "",
                    value: uint256(0)
                });
        }
        return callData[index_];
    }

    struct ReturnData {
        bool success;
        bytes data;
    }

    /// @dev Define fallback response for all calls.
    ReturnData internal defaultReturnData;

    mapping(bytes32 => ReturnData) public givenQueryReturn;
    mapping(bytes32 => bool) public givenQuerySet;
    mapping(bytes32 => bool) public givenQueryLog;

    function setDefaultResponse(ReturnData memory returnData_) external {
        defaultReturnData = returnData_;
    }

    function givenQueryReturnResponse(
        bytes memory query_,
        ReturnData memory returnData_,
        bool log
    ) external {
        bytes32 queryKey = keccak256(query_);
        givenQueryReturn[queryKey] = returnData_;
        givenQuerySet[queryKey] = true;
        givenQueryLog[queryKey] = log;
    }

    function givenSelectorReturnResponse(
        bytes4 selector_,
        ReturnData memory returnData_,
        bool log
    ) external {
        bytes32 queryKey = keccak256(abi.encode(selector_));
        givenQueryReturn[queryKey] = returnData_;
        givenQuerySet[queryKey] = true;
        givenQueryLog[queryKey] = log;
    }

    // prettier-ignore
    fallback(bytes calldata query_) external payable returns (bytes memory){
        bytes32 queryKey = keccak256(query_);
        bytes32 selectorKey = keccak256(abi.encode(msg.sig));
        // Check if any set query matches the current query
        if (givenQuerySet[queryKey] || givenQuerySet[selectorKey]) {
            bytes32 key = givenQuerySet[queryKey] ? queryKey : selectorKey;

            // Log call
            if (givenQueryLog[key]) {
                _logCall();
            }

            // Return data as specified by the query
            ReturnData memory returnData = givenQueryReturn[key];
            require(returnData.success, string(returnData.data));
            return returnData.data;
        } else {
            // Default to sending the default response
            _logCall();
            ReturnData memory returnData = defaultReturnData;
            return returnData.data;
        }
    }

    receive() external payable {
        this;
    }

    function _logCall() internal {
        CallData memory newCallData = CallData({
            caller: msg.sender,
            functionSelector: msg.sig,
            data: msg.data,
            value: msg.value
        });

        callData.push(newCallData);
    }
}
