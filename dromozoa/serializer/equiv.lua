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
local setmetatable = setmetatable
local type = type
local math_type = math.type

local function equiv(a, b, P)
  local t = type(a)
  if t ~= type(b) then
    return false
  elseif t == "nil" or t == "string" or t == "boolean" then
    return a == b
  elseif t == "number" then
    if math_type and math_type(a) ~= math_type(b) then
      return false
    else
      return a == b
    end
  elseif t == "table" then
    local p = P[a]
    if p then
      return p == b
    else
      P[a] = b
    end

    local m = 0
    for k, u in pairs(a) do
      local t = type(k)
      if t == "number" or t == "string" or t == "boolean" then
        if not equiv(u, b[k], P) then
          return false
        end
      elseif t == "table" then
        m = m + 1
      else
        error("table index is " .. t)
      end
    end

    local n = 0
    for k in pairs(b) do
      local t = type(k)
      if t == "number" or t == "string" or t == "boolean" then
        if a[k] == nil then
          r[b] = false
          return false
        end
      elseif t == "table" then
        n = n + 1
      else
        error("table index is " .. t)
      end
    end

    if m == 0 and n == 0 then
      return true
    elseif m ~= n then
      return false
    end

    local map = {}
    for j, u in pairs(a) do
      if type(j) == "table" then
        local found
        for k, v in pairs(b) do
          if not map[k] and type(k) == "table" then
            local Q = { __index = P }
            local Q = setmetatable(Q, Q)
            if equiv(u, v, Q) and equiv(j, k, Q) then
              map[k] = true
              found = true
              P = Q
              break
            end
          end
        end
        if not found then
          return false
        end
      end
    end

    return true
  else
    error("unsupported type " .. t)
  end
end

return function (a, b)
  return equiv(a, b, {})
end
