-- Copyright (C) 2019 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-serializer.
--
-- dromozoa-serializer is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-serializer is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-serializer.  If not, see <http://www.gnu.org/licenses/>.

local error = error
local string_char = string.char

local decoder1 = {}
for v = 0, 255 do
  decoder1[string_char(v)] = v
end

local function read(handle, dict)
  local a, b = handle:read(1, 1)
  if a == "\255" then
    if b == "\1" then
      local ref = handle:read("*n", 1)
      return dict[ref]
    elseif b == "\2" then
      local size = handle:read("*n", 1)
      return handle:read(size)
    elseif b == "\3" then
      return (handle:read("*n", 1))
    elseif b == "\4" then
      return handle:read("*n", 1) + 0.0
    elseif b == "\5" then
      return nil, true
    else
      error(("unknown op 0x%04x"):format(decoder1[a] * 256 + decoder1[b]))
    end
  else
    local a = decoder1[a]
    local b = decoder1[b]
    if a < 64 then
      local ref = a * 256 + b
      return dict[ref]
    elseif a < 128 then
      local size = (a - 64) * 256 + b
      return handle:read(size)
    else
      local ref
      if a < 192 then
        ref = (a - 128) * 256 + b
      elseif a == 192 and b == 0 then
        ref = handle:read("*n", 1)
      else
        error(("unknown op 0x%04x"):format(decoder1[a] * 256 + decoder1[b]))
      end

      local u = {}
      dict[ref] = u

      for i = 1, 4294967295 do
        local v, ended = read(handle, dict)
        if ended then
          break
        end
        u[i] = v
      end

      while true do
        local k, ended = read(handle, dict)
        if ended then
          break
        end
        u[k] = read(handle, dict)
      end

      return u
    end
  end
end

return function (handle)
  local dict = { true, false }
  return read(handle, dict)
end
