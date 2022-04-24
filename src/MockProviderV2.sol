// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {MockProvider} from "./MockProvider.sol";

contract MockProviderV2 is MockProvider {
    function givenQueryRevert(bytes memory query_, bytes memory reason_)
        public
    {}
}
