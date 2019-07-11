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

local function write(handle, u, dict, max, string_dictionary)
  if u == nil then
    handle:write "1 0\n"
  else
    local t = type(u)
    if t == "boolean" then
      if u then
        handle:write "1 1\n"
      else
        handle:write "1 2\n"
      end
    elseif t == "number" then
      if math_type and math_type(u) == "integer" then
        handle:write("2 ", u, "\n")
      elseif u % 1 == 0 then
        handle:write("3 ", u, "\n")
      else
        handle:write("3 ", ("%.17g"):format(u), "\n")
      end
    elseif t == "string" then
      if string_dictionary then
        local ref = dict[u]
        if ref then
          handle:write("1 ", ref, "\n")
        else
          max = max + 1
          handle:write("5 ", max, " ", #u, ":", u, "\n")
          dict[u] = max
        end
      else
        handle:write("4 ", #u, ":", u, "\n")
      end
    elseif t == "table" then
      local ref = dict[u]
      if ref then
        handle:write("1 ", ref, "\n")
      else
        max = max + 1
        local n = #u
        handle:write("6 ", max, " ", n, "\n")
        dict[u] = max

        local written = {}
        for i = 1, n do
          max = write(handle, u[i], dict, max, string_dictionary)
          written[i] = true
        end

        for k, v in pairs(u) do
          if not written[k] then
            max = write(handle, k, dict, max, string_dictionary)
            max = write(handle, v, dict, max, string_dictionary)
          end
        end

        handle:write("7 0\n")
      end
    else
      error(("unsupported type %s"):format(t))
    end
  end

  return max
end

return function (handle, u, string_dictionary)
  handle:write "1\n"
  local dict = {
    [true] = 1;
    [false] = 2;
  }
  write(handle, u, dict, 2, string_dictionary)
end
