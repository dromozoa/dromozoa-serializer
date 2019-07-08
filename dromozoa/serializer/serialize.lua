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

if not math_type then
  math_type = function () end
end

local function write(handle, v, map, n)
  local t = type(v)
  if t == "boolean" then
    if v then
      handle:write "1\n"
    else
      handle:write "2\n"
    end
  elseif t == "number" then
    if math_type(v) == "integer" then
      handle:write("3 ", v, "\n")
    elseif v % 1 == 0 then
      handle:write("4 ", v, "\n")
    else
      handle:write("4 ", ("%.17g"):format(v), "\n")
    end
  elseif t == "string" then
    handle:write("5 ", #v, ":", v, "\n")
  elseif t == "table" then
    local m = map[v]
    if m then
      handle:write("6 ", m, "\n")
    else
      n = n + 1
      handle:write("7 ", n, "\n")
      map[v] = n
      for k, v in pairs(v) do
        n = write(handle, k, map, n)
        n = write(handle, v, map, n)
      end
      handle:write("8\n")
    end
  end
  return n
end

return function (handle, root)
  handle:write "1\n" -- version
  write(handle, root, {}, 0)
end
