local lapis = require("lapis")
local json_params = require("lapis.application").json_params
local requests = require('requests')
local app = lapis.Application()

local WRITE_MEMORY_API = os.getenv("WRITE_MEMORY_API")

app:post("/api/v1/execute", json_params(function(self)
  local firstRegAddress = self.params.state.stackPointer - 1
  if firstRegAddress == 0 then
    firstRegAddress = 0xFFFF
  end

  local secondRegAddress = firstRegAddress - 1
  if secondRegAddress == 0 then
    secondRegAddress = 0xFFFF
  end

  if self.params.opcode == 0xC5 then -- PUSH BC
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = firstRegAddress, value = self.params.state.b }}
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = secondRegAddress, value = self.params.state.c }}
  elseif self.params.opcode == 0xD5 then -- PUSH DE
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = firstRegAddress, value = self.params.state.d }}
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = secondRegAddress, value = self.params.state.e }}
  elseif self.params.opcode == 0xE5 then -- PUSH HL
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = firstRegAddress, value = self.params.state.h }}
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = secondRegAddress, value = self.params.state.l }}
  elseif self.params.opcode == 0xF5 then -- PUSH AF
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = firstRegAddress, value = self.params.state.a }}
    local f = 2
    if self.params.state.flags.sign then
      f = f + 0x80
    end
    if self.params.state.flags.zero then
      f = f + 0x40
    end
    if self.params.state.flags.auxCarry then
      f = f + 0x10
    end
    if self.params.state.flags.parity then
      f = f + 0x04
    end
    if self.params.state.flags.carry then
      f = f + 0x01
    end
    requests.post{WRITE_MEMORY_API, params = {id = self.params.id, address = secondRegAddress, value = f }}
  else
    return { render = "Invalid opcode", status = 400 }
  end

  self.params.state.stackPointer = self.params.state.stackPointer - 2
  if self.params.state.stackPointer < 0 then
    self.params.state.stackPointer = self.params.state.stackPointer + 0xFFFF
  end

  self.params.state.cycles = self.params.state.cycles + 11

  return {
    json = self.params
  }
end))

return app
