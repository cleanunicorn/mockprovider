# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

### Changed


### Removed


## [2.0.0] - 2022-05-01

### Added

- Comments for all code
- `setDefault(bytes memory response_)` method to define a default response for arbitrary requests
- `givenQueryReturn(bytes memory query_, bytes memory response_)` method to define a response for a specified query
- `givenSelectorReturn(bytes4 selector_, bytes memory response_)` method to define a response for a specified selector (`msg.sig`)
- More tests

### Changed

- README.md to describe the current state of your project
- `lib/ds-test` to `2c7dbcc8586b33f358e3307a443e524490c17666`
- `getCallData(uint256 index_)` returns an error `MockProvider__getCallData_indexOutOfBounds(uint256 index)` if an out of bounds `index_` is provided; previously it was returning an empty response

## [1.0.0] - 2022-03-28

### Added

- `getCallData` to return logged requests
- `givenQueryReturnResponse` to make the provider return a specific response for a request
- `setDefaultResponse` to make the provider return a default response for any request
- Issue templates for feature and bug requests
- `givenSelectorReturnResponse` to make the provider return a specific response for a request, without taking into consideration any given parameters. i.e., You can specify to return `42` for any call to `balanceOf(address who)` without having to specify the `who` parameter; it will return `42` for all calls to `balanceOf(address who)`

### Changed

- Upgrade [`cachix/install-nix-action`](https://github.com/cachix/install-nix-action) from `v13` to `v16`
- Downgrade Solidity test version from `0.8.10` to `0.8.7` since it cannot find `0.8.10`
- Migrate repo to work with foundry instead of dapptools
