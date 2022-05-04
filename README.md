# MockProvider

A library for mocking Solidity contracts.

Instead of importing heavy contracts and making sure the setup is complete and correct, you might only need a library to return a value. This library is designed to be used in tests and return values for the contracts you are testing.

## Installation

### Dapptools project

In your dapptools project folder, run:

```sh
$ dapp install https://github.com/cleanunicorn/mockprovider
```

It will create a new folder in `lib` named `mockprovider`.


## Usage

`MockProvider` is created to be used in Solidity based tests. In your test, you can create a `MockProvider` instance and pass it to your contract. Your contract will then be able to call the `MockProvider` instance and use its returned value.

### Return default response for any request

```solidity
MockProvider provider = new MockProvider();

// Make the provider successfully respond with 42 for any request
provider.setDefault(
    abi.encode(uint256(42)
);
```

It will respond with 42 for any request.

For example you could do a low level call to the contract and decode the expected answer.

```solidity
// Do a low level call and check the response
(bool success, bytes memory response) = address(provider).call(
    "0xdeadbeef"
);

assertTrue(success, "Expected success");

(uint256 result) = abi.decode(response, (uint256));
assertEq(result, 42, "Expected 42");
```

Alternatively, and most commonly, you will mock a contract's method that needs to return a value.

Considering you have this contract you need to mock:

```solidity
interface ITheAnswer {
    function theUltimateQuestionOfLifeTheUniverseAndEverything() external returns (uint);
}
```

You can just call the method, once the provider was set to return a response:

```solidity
// Cast the contract as `ITheAnswer` to easily call `.theUltimateQuestionOfLifeTheUniverseAndEverything()`
ITheAnswer theAnswer = ITheAnswer(address(provider));

// Mock the answer to everything
provider.setDefault(
    abi.encode(uint256(42)
);

// Make the call
uint256 theUltimateAnswer = theAnswer.theUltimateQuestionOfLifeTheUniverseAndEverything();

// Check the answer
assertEq(theUltimateAnswer, 42, "Expected 42");
```

### Return specific response for specific request

You can set different responses for different requests with `givenQueryReturn`.

Consider you want to mock this interface

```solidity
interface IOddEven {
    function isEven(uint256 x) external pure returns (bool);
    function isOdd(uint256 x) external pure returns (bool);
    function getOdd() external pure returns (uint256);
    function getEven() external pure returns (uint256);
}
```

You need to initialize your provider

```solidity
provider = new MockProvider();
```

You can make the provider return the number `1` when `getOdd` is called:

```solidity
// Make it return 1 when calling .getOdd()
provider.givenQueryReturn(
    // Respond to `.getOdd()`
    abi.encodePacked(IOddEven.getOdd.selector),
    // With `true`
    abi.encodePacked(uint256(1))
);
```

And return the number `2` when `getEven` is called:

```solidity
// Make it return 2 when calling .getEven()
provider.givenQueryReturn(
    // Respond to `.getEven()`
    abi.encodePacked(IOddEven.getEven.selector),
    // With `2`
    abi.encodePacked(uint256(2))
);
```

You could check the responses to be correct in your tests:

```solidity
// Cast the mock provider as IOddEven to get easy access to
// the methods `getOdd()` and `getEven()`
IOddEven mockOddEven = IOddEven(address(provider));

// Check if it returns odd and even numbers
uint256 oddNumber = mockOddEven.getOdd();
assertTrue(oddNumber % 2 == 1, "Expected odd number");
uint256 evenNumber = mockOddEven.getEven();
assertTrue(evenNumber % 2 == 0, "Expected even number");
```

### Return specific response for a given function selector

You can set different responses for different selectors with `givenSelectorReturnResponse`.

Mocking the same interface as the previous example

You can make the provider return the `false` whenever `isEven` is called:

```solidity
// Make it return false whenever calling .isEven(anything)
provider.givenSelectorReturnResponse(
    // Respond to `.isEven()`
    abi.encodePacked(IOddEven.isEven.selector),
    // Encode the response
    MockProvider.ReturnData({
        success: true,
        data: abi.encodePacked(bool(false))
    }),
    // Log the event
    false
);
```

Setting `givenSelectorReturnResponse` will make the provider return `false` for any call to `isEven`, without the need to specify *all* the numbers.

```solidity
provider.isEven(1) == false
provider.isEven(42) == false
```

### Logging requests

When using `givenQueryReturnResponse` or `givenSelectorReturnResponse` you can also log the requests. The 3rd parameter is a boolean that indicates if the request should be logged.

Let's assume you want to test a contract that makes a call into an external contract. The external contract could be a smart contract that you do not develop, or one that already exists on the blockchain, or even a contract that you develop but needs a complex deployment system. Thus, you want that contract to be mocked and you need to know if it was called.

## Testing

```sh
make test
```
