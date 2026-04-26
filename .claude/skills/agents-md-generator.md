---
name: agents-md-generator
description: Generate / update AGENTS.md for directories, describing purpose of code. Use when user wants to document directory's purpose.
---

# AGENTS.md Generator

This skill guides the generation of `AGENTS.md` files for specific directories. Those files serves as documentation to help AI agents (and humans) understand the high-level purpose and architecture of the code within that directory.

## Workflow

1.  **Deeply Analyze the Directory**:
    *   **List files**: List all files in the target directory, filtering for primary source files by extension (e.g., `.swift`, `.ts`, `.py`).
    *   **Identify core files**: Identify key files (e.g., files matching the directory name, files with `Manager`/`Service`/`Core` suffixes, `README.md`, `Package.swift`, or `*.podspec`).
    *   **Understand context**:
        *   Read the contents of the key files identified above to understand the module's primary responsibilities.
        *   **Search for references**: Search the project root (or `Sources` directory) for the module name or core class name to see how it is used externally. This is critical for writing an accurate "Usage" section.
        *   **Check dependencies**: Examine `import` statements or build configuration to understand which external libraries or internal modules this module depends on.

2.  **Draft Content**:
    *   **Title**: Directory name / module name.
    *   **Summary**: A concise paragraph explaining what the directory contains and its primary role. If it is part of a larger system, describe its responsibility within.
    *   **Core Components**:
        *   List important components (files or subdirectories). Not to list all (<= 5) because they are subject to changes. List those that best helps understanding the directory.
        *   Briefly describe the responsibilities of each component.
        *   Also the relationship among them iff it is hard to understand.
    *   **Usage / Interaction**:
        *   Based on search results from step 1, provide real usage examples.
        *   If no external usage is found (e.g., new module), construct reasonable **theoretical examples** based on the `public` interface and initialization methods (`init`).
        *   Describe the main entry points and key interaction flows.

3.  **Generate AGENTS.md**:
    *   Create (or overwrite) `AGENTS.md` in the target directory.
    *   Write the drafted content in Markdown format.

## Template

Follow this structure when generating `AGENTS.md` (hints in parentheses are guides):

```markdown
# [Directory Name]

## Purpose
[Description of what this directory does and why it exists. Explain the problems it solves and its role within the overall project.]

## Core Components
- **[File/Subdirectory Name]**: [Description of responsibilities]
- ...

## Architecture & Patterns
[Optional. Describe the design patterns used here (e.g., Singleton, Factory, Delegate), architectural styles (e.g., MVVM, Layered), or important technical decisions (e.g., using Actor for concurrency control, using Extension to extend standard libraries).]

## Usage
[How to use the code in this directory. Subtitles below are just examples. Sometimes one example is enough. Sometimes 3 for different modes.]

### [Scenario 1: Basic Usage]
```swift
[Code example]
```

### [Scenario 2: Advanced Configuration (optional)]
```swift
[Code example]
```

## Guidelines

-   **Be Specific**: Avoid generic descriptions. Reference actual class names and functions from the code.
-   **Context-Aware**: If the directory contains a specific module of a larger system, explain its role within that system.
-   **No Hallucination**: Only describe things that actually exist. If usage examples are inferred from interfaces, ensure they are syntactically and logically correct.
-   **Code References**: When mentioning class names or methods in descriptions, wrap them in backticks (e.g., `MyManager`, `init()`).
-   **Generate recursively**: Unless told to only touch mentioned folders / files, generate for subdirectories that worth. Worthy examples: sources folder containing multiple files, like `Sources/ModuleOne/SubmoduleA1/Protocols`, `Sources/SomeName/Core`. Unworthy: `Sources` itself given that there is already root-level AGENTS.md, `Tests/**` unless unexpectedly complex, `Sources/SomeName` containing only one trival file, resources / assets folders. Forbidden unless asked for: `.git`, `.tool-name/**`, git-ignored dirs, `node_modules` and its like
