{ lib }: {
  # Asserts a file exists at build time (for config source validation)
  assertFileExists = path: message:
    assert builtins.pathExists path || throw message; path;
}
