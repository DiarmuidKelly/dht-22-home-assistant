# Changelog

## [1.1.0] - 2025-11-19

### Changes

- Release created from PR merge


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-11-19

### Added
- Initial production release
- DHT22 temperature and humidity sensor reading
- MQTT publishing to Home Assistant
- MQTT Discovery for automatic sensor configuration
- WiFi connection management with auto-reconnect
- Detailed logging system with rotation
- LED status indicators
- Version tracking and reporting

### Fixed
- Negative temperature handling for DHT22 sensor
  - Fixed issue where temperatures below 0°C were incorrectly read as -3274°C
  - Properly handle DHT22's sign bit (bit 15) for negative temperatures
  - Temperature values now correctly displayed for sub-zero conditions

### Technical Details
- Added `__version__` constant for semantic versioning
- Version included in device info sent to Home Assistant
- Version logged on application startup
- Proper two's complement handling for negative temperature values

[Unreleased]: https://github.com/DiarmuidKelly/dht-22-ha/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/DiarmuidKelly/dht-22-ha/releases/tag/v1.0.0
