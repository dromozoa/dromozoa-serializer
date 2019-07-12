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

local N = 16

local function write(handle, u, dict, max, var, depth)
  if u == nil then
    handle:write(var, depth, "=nil\n")
  else
    local t = type(u)
    if t == "boolean" then
      if u then
        handle:write(var, depth, "=true\n")
      else
        handle:write(var, depth, "=false\n")
      end
    elseif t == "number" then
      if math_type and math_type(u) == "integer" then
        handle:write(var, depth, "=", u, "\n")
      elseif u % 1 == 0 then
        handle:write(var, depth, "=", u, "+0.0\n")
      else
        handle:write(var, depth, "=", ("%.17g"):format(u), "\n")
      end
    elseif t == "string" then
      local ref = dict[u]
      if ref then
        handle:write(var, depth, "=d[", ref, "]\n")
      else
        max = max + 1
        handle:write(var, depth, "=", ("%q"):format(u), "\n")
        handle:write("d[", max, "]=", var, depth, "\n")
        dict[u] = max
      end
    elseif t == "table" then
      local ref = dict[u]
      if ref then
        handle:write(var, depth, "=d[", ref, "]\n")
      else
        max = max + 1
        handle:write(var, depth, "={}\n")
        handle:write("d[", max, "]=", var, depth, "\n")
        dict[u] = max

        local new_depth = depth + 1

        local written = {}
        for i = 1, #u do
          max = write(handle, u[i], dict, max, "v", new_depth)
          handle:write(var, depth, "[", i, "]=v", new_depth, "\n")
          written[i] = true
        end

        for k, v in pairs(u) do
          if not written[k] then
            max = write(handle, k, dict, max, "k", new_depth)
            max = write(handle, v, dict, max, "v", new_depth)
            handle:write(var, depth, "[k", new_depth, "]=v", new_depth, "\n")
          end
        end
      end
    else
      error("unsupported type " .. t)
    end
  end

  return max
end

return function (handle, u)
  local dict = {
    [true] = 1;
    [false] = 2;
  }
  handle:write [[
2
local d={}
]]
  for i = 1, N do
    handle:write("local k", i, "\n")
    handle:write("local v", i, "\n")
  end

  write(handle, u, dict, 0, "v", 1)
  handle:write "return v1\n"
end
