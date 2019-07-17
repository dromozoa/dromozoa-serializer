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
local pairs = pairs
local tostring = tostring
local type = type
local math_type = math.type
local string_char = string.char
local string_pack = string.pack

local encoder1 = {}
for v = 0, 255 do
  encoder1[v] = string_char(v)
end

local function write(handle, u, dict, max, string_dictionary)
  if u == nil then
    handle:write "\1\0"
  else
    local t = type(u)
    if t == "boolean" then
      if u then
        handle:write "\1\1"
      else
        handle:write "\1\2"
      end
    elseif t == "number" then
      if math_type and math_type(u) == "integer" then
        local s = tostring(u)
        handle:write("\3", encoder1[#s], s, " ")
      else
        local s = ("%.17g"):format(u)
        handle:write("\4", encoder1[#s], s, " ")
      end
    elseif t == "string" then
      if string_dictionary then
        error "???"
      else
        local size = #u
        if size < 256 then
          handle:write("\5", encoder1[size], u)
        else
          local s = tostring(size)
          handle:write("\6", encoder1[#s], s, " ", u)
        end
      end
    elseif t == "table" then
      local ref = dict[u]
      if ref then
        if ref < 256 then
          handle:write("\1", encoder1[ref])
        else
          local s = tostring(ref)
          handle:write("\2", encoder1[#s], s, " ")
        end
      else
        max = max + 1
        if max < 256 then
          handle:write("\7", encoder1[max])
        else
          local s = tostring(max)
          handle:write("\8", encoder1[#s], s, " ")
        end
        dict[u] = max

        local written = {}
        for i = 1, #u do
          max = write(handle, u[i], dict, max, string_dictionary)
          written[i] = true
        end

        handle:write "\9\0"

        for k, v in pairs(u) do
          if not written[k] then
            max = write(handle, k, dict, max, string_dictionary)
            max = write(handle, v, dict, max, string_dictionary)
          end
        end

        handle:write "\9\0"
      end
    else
      error("unsupported type " .. t)
    end
  end

  return max
end

return function (handle, u, string_dictionary)
  local dict = { [true] = 1, [false] = 2 }
  handle:write "2\n"
  write(handle, u, dict, 2, string_dictionary)
end
