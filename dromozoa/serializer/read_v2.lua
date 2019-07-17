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
local tonumber = tonumber
local string_char = string.char
local string_unpack = string.unpack

local decoder1 = {}
for v = 0, 255 do
  decoder1[string_char(v)] = v
end

local function read(handle, dict)
  local op, a = handle:read(1, 1)
  if op == "\1" then
    return dict[decoder1[a]]
  elseif op == "\2" then
    return dict[handle:read("*n", 1)]
  elseif op == "\3" then
    return (handle:read("*n", 1))
  elseif op == "\4" then
    return handle:read("*n", 1) + 0.0
  elseif op == "\5" then
    return handle:read(decoder1[a])
  elseif op == "\6" then
    local size = handle:read("*n", 1)
    return handle:read(size)
  elseif op == "\9" then
    return nil, true
  else
    local ref
    if op == "\7" then
      ref = decoder1[a]
    elseif op == "\8" then
      ref = handle:read("*n", 1)
    else
      error("unknown op " .. op)
    end
    local u = {}
    dict[ref] = u

    for i = 1, 4294967295 do
      local v, ended = read(handle, dict)
      if ended then
        break
      end
      u[i] = v
    end

    while true do
      local k, ended = read(handle, dict)
      if ended then
        break
      end
      u[k] = read(handle, dict)
    end

    return u
  end
end

return function (handle)
  local dict = { true, false }
  return read(handle, dict)
end
