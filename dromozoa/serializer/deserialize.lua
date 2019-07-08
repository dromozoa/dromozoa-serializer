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

local function deserialize_value(handle, op, map)
  if op == 1 then
    return false
  elseif op == 2 then
    return true
  elseif op == 3 or op == 4 then
    return handle:read "*n"
  elseif op == 5 then
    local n = handle:read "*n"
    handle:read(1) -- ":"
    local result = handle:read(n)
    return result
  elseif op == 6 then
    local n = handle:read "*n"
    local result = {}
    map[n] = result
    return result
  elseif op == 7 then
    local n = handle:read "*n"
    return map[n]
  else
    error(("unknown op %s"):format(op))
  end
end

local function deserialize(handle)
  local map = {}

  local op = handle:read "*n"
  local result = deserialize_value(handle, op, map)

  local u
  while true do
    local op = handle:read "*n"
    if not op then
      break
    end
    if op == 8 then
      local n = handle:read "*n"
      u = map[n]
    else
      local k = deserialize_value(handle, op, map)
      local op = handle:read "*n"
      local v = deserialize_value(handle, op, map)
      u[k] = v
    end
  end

  return result
end

return function (handle)
  local version = handle:read "*n"
  if version == 1 then
    return deserialize(handle)
  end
end
