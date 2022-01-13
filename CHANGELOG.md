# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added 

- `getCallData` to return logged requests
- `givenQueryReturnResponse` to make the provider return a specific response for a request
- `setDefaultResponse` to make the provider return a default response for any request
- Issue templates for feature and bug requests

### Changed

- Upgrade [`cachix/install-nix-action`](https://github.com/cachix/install-nix-action) from `v13` to `v16`
- Downgrade Solidity test version from `0.8.10` to `0.8.7` since it cannot find `0.8.10`