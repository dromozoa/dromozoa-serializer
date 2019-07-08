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

local pairs = pairs
local type = type
local math_type = math.type

local function write(handle, u, map, max)
  local t = type(u)
  if t == "nil" then
    handle:write "0\n"
  elseif t == "boolean" then
    if u then
      handle:write "1\n"
    else
      handle:write "2\n"
    end
  elseif t == "number" then
    if math_type and math_type(u) == "integer" then
      handle:write("3 ", u, "\n")
    elseif u % 1 == 0 then
      handle:write("4 ", u, "\n")
    else
      handle:write("4 ", ("%.17g"):format(u), "\n")
    end
  elseif t == "string" then
    handle:write("5 ", #u, ":", u, "\n")
  elseif t == "table" then
    local ref = map[u]
    if ref then
      handle:write("6 ", ref, "\n")
    else
      max = max + 1
      local n = #u
      handle:write("7 ", max, " ", n, "\n")
      map[u] = max

      local written = {}
      for i = 1, n do
        max = write(handle, u[i], map, max)
        written[i] = true
      end

      for k, v in pairs(u) do
        if not written[k] then
          max = write(handle, k, map, max)
          max = write(handle, v, map, max)
        end
      end

      handle:write("8\n")
    end
  else
    error(("unsupported type %s"):format(t))
  end
  return max
end

local function build(buffer, i, u, map, max)
  local t = type(u)
  if t == "boolean" then
    if u then
      i = i + 1
      buffer[i] = "1"
    else
      i = i + 1
      buffer[i] = "2"
    end
  elseif t == "number" then
    if math_type and math_type(u) == "integer" then
      i = i + 1
      buffer[i] = "3"
      i = i + 1
      buffer[i] = u
    elseif u % 1 == 0 then
      i = i + 1
      buffer[i] = "4"
      i = i + 1
      buffer[i] = u
    else
      i = i + 1
      buffer[i] = "4"
      i = i + 1
      buffer[i] = ("%.17g"):format(u)
    end
  elseif t == "string" then
    i = i + 1
    buffer[i] = "5"
    i = i + 1
    buffer[i] = #u .. ":" .. u
  elseif t == "table" then
    local ref = map[u]
    if ref then
      i = i + 1
      buffer[i] = "6"
      i = i + 1
      buffer[i] = ref
    else
      max = max + 1
      i = i + 1
      buffer[i] = "7"
      i = i + 1
      buffer[i] = max
      map[u] = max
      for k, v in pairs(u) do
        i, max = build(buffer, i, k, map, max)
        i, max = build(buffer, i, v, map, max)
      end
      i = i + 1
      buffer[i] = "8"
    end
  end
  return i, max
end

return function (handle, u)
  handle:write "1\n"
  -- print(collectgarbage "count")
  write(handle, u, {}, 0)
  -- local buffer = {}
  -- build(buffer, 0, u, {}, 0)
  -- print(collectgarbage "count")
  -- for i = 1, #buffer do
  --   handle:write(buffer[i], "\n")
  -- end
  -- local s = table.concat(buffer, "\n")
  -- print(collectgarbage "count")
  -- handle:write(s, "\n")
  -- print(collectgarbage "count")
end
