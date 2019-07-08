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
  if t == "boolean" then
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
      handle:write("7 ", max, "\n")
      map[u] = max
      for k, v in pairs(u) do
        max = write(handle, k, map, max)
        max = write(handle, v, map, max)
      end
      handle:write("8\n")
    end
  end
  return max
end

return function (handle, root)
  handle:write "1\n"
  write(handle, root, {}, 0)
end
