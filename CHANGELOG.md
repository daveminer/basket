
# Change Log

## [0.2.1] - 2024-04-02

- Removed .gitignore entry for client hooks directory

### Added

### Changed

- Ticker table now uses a client hook to process ticker updates, rather than keeping
  previous state on the server.

### Fixed

- Change highlighting no longer triggers when tickers are added or removed.


## [0.2.0] - 2024-04-01


### Added

- Ticker table now uses the LiveView in streaming mode with the append option.

### Changed

### Fixed

- Change highlighting no longer triggers when tickers are added or removed.
