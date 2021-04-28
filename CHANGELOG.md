# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

* None.

## [0.2.3 (2021-04-28)]

### Changed

* Update RxSwift to 6.1.0

## [0.2.2 (2020-08-11)]

### Added

* Add `encoder` parameter to `URLKit.ParameterEncodingStrategy.urlEncodedFormParameter`
* Add `parameterEncodingStrategy` parameter to `URLKit.Session`, `HTTPURLKit.Session`, `HTTPURLKit.OAuthSession`

## [0.2.1 (2020-08-11)]

### Added

* Add `credential` parameter to `OAuthSession.init`

## [0.2.0 (2020-08-11)]

### Added

* Add `credential` proeprty to `OAuthSession`

### Changed

* Raname `OAuthCredentialManager` to `OAuthAuthenticator`
* Rename `OAuthSession.credentialManager` to `OAuthSession.authenticator`

## [0.1.0 (2020-08-11)]

* First release.

[Unreleased]: https://github.com/ridi/RIDIFoundation-iOS/compare/0.2.3...HEAD
[0.2.3 (2021-04-28)]: https://github.com/ridi/RIDIFoundation-iOS/compare/0.2.2...0.2.3
[0.2.2 (2020-08-11)]: https://github.com/ridi/RIDIFoundation-iOS/compare/0.2.1...0.2.2
[0.2.1 (2020-08-11)]: https://github.com/ridi/RIDIFoundation-iOS/compare/0.2.0...0.2.1
[0.2.0 (2020-08-11)]: https://github.com/ridi/RIDIFoundation-iOS/compare/0.1.0...0.2.0
[0.1.0 (2020-08-11)]: https://github.com/ridi/RIDIFoundation-iOS/releases/tag/0.1.0
