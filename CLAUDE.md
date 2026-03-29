# AirTraffic — MCP Server Framework for AIRL

## Overview

General-purpose MCP (Model Context Protocol) server framework written in pure AIRL, compiled with g3. Lets AI agents build MCP servers that expose tools to Claude Code. Handles JSON-RPC 2.0 protocol, tool registration, input validation, and stdio transport.

**Design spec:** `~/repos/airtools/docs/superpowers/specs/2026-03-29-mcp-workflow-server-design.md`

## Building & Running

Compiled to native binaries using g3 (the AIRL self-hosted compiler). Must have g3 built first.

```bash
# Build an AirTraffic server
./build.sh examples/calculator.airl -o calculator-server

# Run it (Claude Code launches via MCP config, but for testing):
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}' | ./calculator-server

# Run tests
bash tests/test.sh
```

## Architecture

Four modules, loaded in order:

```
transport.airl  →  jsonrpc.airl  →  schema.airl  →  airtraffic.airl  →  <user-server>.airl
(stdin/stdout)     (JSON-RPC 2.0)   (validation)    (core framework)     (tools + main)
```

All modules loaded via g3 `--load` flags (flat namespace). Function names prefixed to avoid collisions:
- `at-*` — transport functions
- `jsonrpc-*` — JSON-RPC functions
- `schema-*` — validation functions
- `airtraffic-*` — core framework functions

## Dependencies

- **g3 compiler** — `~/repos/AIRL/g3` (must be built via `bash ~/repos/AIRL/scripts/build-g3.sh`)
- **AIRL stdlib** — auto-loaded by g3
- **No external dependencies**

## Key AIRL Builtins Used

| Builtin | Purpose |
|---------|---------|
| `json-parse` | Parse incoming JSON-RPC messages (returns Result) |
| `json-stringify` | Serialize outgoing JSON-RPC responses |
| `map-from`, `map-get`, `map-set`, `map-has` | Build/inspect JSON objects as AIRL maps |
| `shell-exec` | v0.1 stdin workaround (`head -n 1`) — will be replaced by `read-line` builtin |
| `println` | Write JSON-RPC responses to stdout |
| `type-of` | Runtime type checking for schema validation |

## Conventions

- All functions have `:sig`, `:requires`, `:ensures` contracts
- Multi-binding `let` preferred: `(let (x : T v1) (y : T v2) body)`
- Error handling via Result variants: `(Ok value)` / `(Err message)`
- Tool handlers take one argument (args Map) and return Result
- No mixed int/float — use `int-to-float` when needed
- `and`/`or` are eager — use nested `if` for short-circuit

## MCP Protocol Support (v0.1)

| Method | Status |
|--------|--------|
| `initialize` | Supported |
| `notifications/initialized` | Supported (no response) |
| `tools/list` | Supported |
| `tools/call` | Supported (with schema validation) |
| Resources, Prompts, Sampling | Not yet |
| SSE/HTTP transport | Not yet (stdio only) |

## Known Limitations

1. **No `read-line` builtin** — stdin reading uses `shell-exec "head" ["-n" "1"]` which spawns a process per message. A Requirement Spec has been filed to repos/AIRL for a proper `read-line` builtin.
2. **stdout flushing** — `println` may not flush immediately on all platforms. If responses don't reach Claude Code, check buffering.
3. **JSON Schema subset** — only `type`, `properties`, `required`, and `enum` are validated. No `$ref`, `oneOf`, `pattern`, etc.
