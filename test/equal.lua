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

local function equal(a, b, dict)
  if a == b then
    return true
  elseif type(a) == "table" and type(b) == "table" then
    if dict[a] then
      return true
    else
      dict[a] = true
    end
    for k, u in pairs(a) do
      local v = b[k]
      if v == nil or not equal(u, v, dict) then
        return false
      end
    end
    for k, v in pairs(b) do
      local u = a[k]
      if u == nil then
        return false
      end
    end
    return true
  else
    return false
  end
end

return function (a, b)
  return equal(a, b, {})
end
