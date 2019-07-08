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

local function read(handle, op, map)
  if op == 0 then
    return nil
  elseif op == 1 then
    return true
  elseif op == 2 then
    return false
  elseif op == 3 or op == 4 then
    return handle:read "*n"
  elseif op == 5 then
    local n = handle:read("*n", 1)
    return handle:read(n)
  elseif op == 6 then
    local ref = handle:read "*n"
    return map[ref]
  elseif op == 7 then
    local ref, n = handle:read("*n", "*n")
    local u = {}
    map[ref] = u

    for i = 1, n do
      local op = handle:read "*n"
      local v = read(handle, op, map)
      u[i] = v
    end

    while true do
      local op = handle:read "*n"
      if op == 8 then
        break
      end
      local k = read(handle, op, map)
      local op = handle:read "*n"
      local v = read(handle, op, map)
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
    return read(handle, op, {})
  else
    error(("unknown version %d"):format(version))
  end
end