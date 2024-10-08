# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2024-10-06

### Changed
- Adjusting date type to display calendar
- Allowing to add expired certificates

### Added
- totalBottomTime to statistics

## [1.1.0] - 2024-09-19

### Added
- Loading icon when the list of dive sites is loading in the dive log

### Changed
- Dive log button color

### Fixed
- Do not allow screen rotation, leave the screen vertical only
- Allows you to remove the image from the certificate when editing it

## [1.1.0-beta] - 2024-09-13

### Added
- **Functional Requirements:**
  - RF1: The system must allow new users to register.
  - RF2: The system must allow users to log in.
  - RF3: The system must allow users to record information about their dives.
  - RF4: The system must allow users to register new dive sites.
  - RF5: The system must allow users to rate dive sites.
  - RF6: Users must be able to view maps with the geographic locations of dive sites.
  - RF7: The system must allow users to register their diving certificates.
  - RF8: Users must be able to edit their profiles.
  - RF9: The system must allow users to view statistics about their dives.
  - RF10: Users must be able to filter their previous dive records by diving period or region.

- **Non-functional Requirements:**
  - NF1: The mobile system must operate on Android and iOS devices.

## [1.0.0] - 2024-05-09

### Added
- Initial project architecture.
- Libraries:
  - `flutter_secure_storage`
  - `http`
  - `flutter_form_builder`

### Changed
- Updated `flutter_lints` to v3.0.2
- Changed application icon and name
- Refactored `settings.gradle` and `build.gradle`