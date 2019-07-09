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

local function read(handle, op, dict)
  if op == 1 then
    local ref = handle:read "*n"
    return dict[ref]
  elseif op == 2 or op == 3 then
    return handle:read "*n"
  elseif op == 4 then
    local size = handle:read("*n", 1)
    return handle:read(size)
  elseif op == 6 then
    local ref, size = handle:read("*n", "*n")
    local u = {}
    dict[ref] = u

    for i = 1, size do
      local op = handle:read "*n"
      local v = read(handle, op, dict)
      u[i] = v
    end

    while true do
      local op = handle:read "*n"
      if op == 7 then
        handle:read "*n"
        break
      end
      local k = read(handle, op, dict)
      local op = handle:read "*n"
      local v = read(handle, op, dict)
      u[k] = v
    end

    return u
  else
    error(("unknown op %s"):format(op))
  end
end

return function (handle)
  local version = handle:read "*n"
  if version == 1 then
    local op = handle:read "*n"
    local dict = { true, false }
    return read(handle, op, dict)
  else
    error(("unknown version %d"):format(version))
  end
end
