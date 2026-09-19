# LC-3 in CMake

An LC-3 emulator implemented entirely in CMake.

## Usage

```bash
cmake -P lc3.cmake example.asm
```

## Testing

Unit tests:

```bash
cmake -P test/test.cmake
```

Full [lc3-test-suite](https://github.com/lc3-test-suite) via the runner:

```bash
./runner.py "cmake -P lc3.cmake %s" -q
```
