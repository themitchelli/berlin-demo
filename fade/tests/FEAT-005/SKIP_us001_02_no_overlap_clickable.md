# SKIP: US-001 AC-02 "At 1280x720 nothing overlaps and every control is clickable"

Not testable from a shell script. Overlap and hit-testing depend on real layout
(grid sizing, font metrics, flex wrapping) that only a rendering browser can
compute. No browser or screenshot tool is available without external
dependencies. The ENGINEERING_LOG.md FEAT-005 entry records the manual check at
a 633 px tall viewport. Static CSS checks that bound this risk are covered by
test_us001_01 (100vh grid, overflow hidden) and test_us001_03 (no external assets).
