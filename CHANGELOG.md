# Changelog

All notable changes to this project will be documented in this file following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format and adhering to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Initial `CHANGELOG.md` with structure and first release notes placeholder.
- Directory rename to `cc-commands/` and `cc-hooks/` reflected across docs and code.

### Changed
- Documentation paths updated after directory rename.

## [0.1.0] - 2025-07-21
### Added
- First public release of Claude Code Flow.
- README in Japanese with detailed workflow, updater, and directory structure.
- `cc-update` self-updater script with colorized diff summary and non-interactive mode.
- Optional modern tool detection (`detect-tools.sh`).
- Git hooks for auto-commit, lint checking, protect rules, link checking.
- Session handoff note template specification under `.ccflow/NOTE/`.

### Changed
- Reorganization of template vs runtime directories.

### Removed
- Temporary `summary.txt` file and other unnecessary files.

[Unreleased]: https://github.com/tsutomu-n/cc-flow/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tsutomu-n/cc-flow/releases/tag/v0.1.0
