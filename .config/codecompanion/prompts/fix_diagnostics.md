---
name: Fix LSP diagnostics
interaction: chat
description: Fix the LSP diagnostics for the selected code
opts:
  alias: lsp_fix
  is_slash_cmd: false
  modes:
    - v
  stop_context_insertion: true
---

## system

You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages. When appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting and suggest fixing the issues directly.

## user

File context: #{buffer}

The programming language is ${context.filetype}. This is a list of the diagnostic messages:

#{diagnostics}

Please fix the underlying issues.
