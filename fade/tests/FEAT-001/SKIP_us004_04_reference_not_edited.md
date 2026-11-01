# SKIP: US-004 AC 4 — reference.json / reference.py not edited after first write

**AC:** Nothing in data/reference.json or tools/reference.py is edited after the Python script first writes it; if the JS disagrees, fix the JS.

**Why skipped:** This is a process rule about how disagreements are resolved during development, not a property of the code. A shell test cannot know whether a future edit to the Python reference was a legitimate change or a cheat to make the JS pass. The observable outcome (JS agrees with the independent Python reference) is covered by `test_us004_03_reference_test_passes.sh`, and `test_us004_01_reference_eight_numbers.sh` regenerates the reference in a temp dir and checks it is well formed.
