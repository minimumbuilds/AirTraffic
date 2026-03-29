# AirTraffic

MCP server framework for AIRL. Build [Model Context Protocol](https://modelcontextprotocol.io/) servers in pure AIRL, compiled to native binaries with g3.

## Quick Start

```clojure
;; calculator.airl — a complete MCP server

(let (server (airtraffic-new "calculator" "0.1.0"))
  (let (server (airtraffic-tool server
    (map-from ["name" "add"
               "description" "Add two numbers"
               "schema" (map-from ["type" "object"
                                   "properties" (map-from ["a" (map-from ["type" "integer"])
                                                           "b" (map-from ["type" "integer"])])
                                   "required" ["a" "b"]])
               "handler" (fn [args]
                           (Ok (+ (map-get args "a") (map-get args "b"))))])))
    (airtraffic-serve server)))
```

```bash
# Build
./build.sh calculator.airl -o calculator-server

# Add to Claude Code
# ~/.claude/mcp.json:
# {
#   "mcpServers": {
#     "calculator": { "command": "/path/to/calculator-server" }
#   }
# }
```

## Requirements

- g3 compiler (`~/repos/AIRL/g3`)

## License

Part of the AIRL project ecosystem.
