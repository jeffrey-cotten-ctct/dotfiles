---
applyTo: "**/*.cpp, **/*.cc, **/*.cxx, **/*.h, **/*.hpp, **/*.hxx"
---
# C++ Naming & Formatting Conventions

> **Source:** [C++ Style Guidelines — Naming](https://ctctjv.atlassian.net/wiki/spaces/DC/pages/45908133/C+Style+Guidelines#Naming)

## Header Files

- Use `#pragma once` instead of `#define` guards.

## Naming

- **File names**: Upper camel case (e.g. `SomeFileName.cpp`), usually matching the class name.
- **Unit test file names**: Test files live in a subdirectory beneath the units being tested, named `<FunctionalityBeingTested>Test.cpp` (suffix, not prefix).
- **Member variables**: Use the prefix `m_` (e.g. `m_Value`), not a suffix.
- **Variable names**: Upper camel case (e.g. `SomeVariableName`).
- **Acronyms**: Remain fully capitalised (e.g. `SomeABCValue`).
- **Enumerators** (plain `enum`): Use `eValue` prefix (e.g. `eRunning`).
- **Enum class enumerators**: No prefix — the enum name already qualifies it (e.g. `State::Running`).
- **Constants**: Use `kValue` prefix for constants only.
- **No Hungarian notation**: Do not use prefixes like `p`, `i`, or `c` to encode types.
  - ✅ `auto* Point`
  - ❌ `auto* pPoint`

## Formatting

- **Brace placement**: Opening brace on its own line (Allman style).
- **Indentation**: Spaces only, 2 spaces per level.
- **Braces always required**: Every `if`, `while`, `for`, etc. body must have braces, even single-statement bodies.

```cpp
if (blah)
{
  blah = false;
}
```

## Preprocessor Macros

- Use **platform macros** (e.g. `PLATFORM_R2`) for code specific to a hardware platform.
- Use **OS macros** (`_unix`, `__linux__`, `__APPLE__`, `_WIN32`) for code specific to an operating system.
- Do not use OS macros for platform-specific code, or vice versa — conflating them causes problems when new platforms are introduced.
