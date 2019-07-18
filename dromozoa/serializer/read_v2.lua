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

local function read(handle, dict, max)
  local a, b = handle:read(1, 1)
  if a == "\255" then
    if b == "\1" then
      local ref = handle:read("*n", 1)
      return dict[ref], max
    elseif b == "\2" then
      local size = handle:read("*n", 1)
      return handle:read(size), max
    elseif b == "\3" then
      local size = handle:read("*n", 1)
      local u = handle:read(size)
      max = max + 1
      dict[max] = u
      return u, max
    elseif b == "\4" then
      return handle:read("*n", 1), max
    elseif b == "\5" then
      return handle:read("*n", 1) + 0.0, max
    elseif b == "\6" then
      local u = {}
      max = max + 1
      dict[max] = u

      local v, ended

      for i = 1, 4294967295 do
        v, max, ended = read(handle, dict, max)
        if ended then
          break
        end
        u[i] = v
      end

      while true do
        v, max, ended = read(handle, dict, max)
        if ended then
          break
        end
        u[v], max = read(handle, dict, max)
      end

      return u, max
    elseif b == "\7" then
      return nil, max, true
    else
      error(("unknown op 0x%04x"):format(decoder1[a] * 256 + decoder1[b]))
    end
  else
    local a = decoder1[a]
    local b = decoder1[b]
    if a < 64 then
      if a == 0 then
        return dict[b], max
      else
        local ref = a * 256 + b
        return dict[ref], max
      end
    elseif a < 128 then
      if a == 64 then
        return handle:read(b), max
      else
        local size = (a - 64) * 256 + b
        return handle:read(size), max
      end
    elseif a < 192 then
      if a == 128 then
        local u = handle:read(b)
        max = max + 1
        dict[max] = u
        return u, max
      else
        local size = (a - 128) * 256 + b
        local u = handle:read(size)
        max = max + 1
        dict[max] = u
        return u, max
      end
    else
      error(("unknown op 0x%04x"):format(decoder1[a] * 256 + decoder1[b]))
    end
  end
end

local function read(handle, dict, max)
  local op, x = handle:read("*n", "*n")
  if op == 1 then
    return max, dict[x]
  elseif op == 2 then
    return max, x
  elseif op == 3 then
    return max, x + 0.0
  elseif op == 4 then
    local _, u = handle:read(1, x)
    return max, u
  elseif op == 5 then
    local _, u = handle:read(1, x)
    max = max + 1
    dict[max] = u
    return max, u
  elseif op == 6 then
    local u = {}
    max = max + 1
    dict[max] = u

    for i = 1, x do
      max, u[i] = read(handle, dict, max)
    end

    local k
    while true do
      max, k = read(handle, dict, max)
      if k == nil then
        break
      end
      max, u[k] = read(handle, dict, max)
    end

    return max, u
  elseif op == 7 then
    return max, nil
  else
    error("unknown op " .. op)
  end
end

return function (handle)
  local dict = { true, false }
  local _, u = read(handle, dict, 2)
  return u
end
