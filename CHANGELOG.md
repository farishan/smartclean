# Changelog

## v0.2.6
- Robust JSON string escaping for control characters in scan output.
- Added regression tests for JSON escaping.

## v0.2.5
- Added argument validation for --target, --keep-days, --min-large, --timeout, and --category.
- Added invalid-argument smoke tests.

## v0.2.4
- Block .env and key/certificate filenames in sensitive-data checks.
- Added safety tests.

## v0.2.3
- Moved json_escape helper into safety.sh and tested it.
- Respect NO_COLOR environment variable.

## v0.2.2
- Reduced false-positive dist artifact detection.
- Added --version flag and safety tests.
- Added CI smoke-test workflow.

## v0.2.1
- Reduced false-positive dist artifacts.
- JSON string escaping and skill package sync.

## v0.2.0
- Cross-platform macOS + Linux support.
- Agensi skill package.

## v0.1.0
- Initial release.
