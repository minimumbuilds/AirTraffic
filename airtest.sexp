(airtest
  (sources ["src/airtraffic.airl"
            "src/jsonrpc.airl"
            "src/schema.airl"
            "src/transport.airl"])
  (tests   "tests/")
  (stdlib  true)
  (g3      "../AIRL/g3"))
