# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2025-10-28

### Fixed
- Fixed floating point precision issue in `getPlaceIdsInBounds()` that caused some place IDs to return incorrect counts
  - Changed from `Math.floor()` to `Math.round()` when calculating grid steps
  - This fixes cases where floating point arithmetic produces values like 1.9999... instead of 2.0
  - Now all size 2 regions correctly return 4 places regardless of geographic location

## [1.2.1] - 2025-10-28

### Fixed
- Fixed off-by-one error in `getPlaceIdsInBounds()` that caused multi-place regions to include an extra row of places
  - The latitude loop was using `<=` instead of `<`, resulting in incorrect place counts
  - For example, size 2 regions were returning 6 places (3×2 grid) instead of 4 places (2×2 grid)
  - This bug affected all multi-place regions with size > 1

### Changed
- Updated test expectations to reflect correct behavior after bug fix
- Added comprehensive tests for `getPlaceIdsForSizedBlockPlace()` with size 1, 2, and 3

## [1.2.0] - Previous release
- Multi-place region support with northwest corner convention

