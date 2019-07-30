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

local serializer = require "dromozoa.serializer"

local function equal(a, b)
  local r1 = serializer.equal(a, b)
  local r2 = serializer.equal(b, a)
  assert(r1 == r2)
  return r1
end

local x = { a = { b = { [1.0] = 42 } } }
local y = { a = { b = { [1] = 42 } } }

assert(equal(x, y))

local x = { a = { b = { [1.0] = 42 } } }
local y = { a = { b = { [1] = 42.0 } } }
if math.type then
  assert(not equal(x, y))
else
  assert(equal(x, y))
end

local x1 = {}
local x2 = { to = x1 }
x1.to = x2

local y1 = {}
local y2 = { to = y1 }
y1.to = y2

assert(equal(x1, y1))
assert(equal(x2, y1))

x1.v = 17
x2.v = 42
y1.v = 17
y2.v = 42

assert(equal(x1, y1))
assert(not equal(x2, y1))

local x1 = { 17, 23, 42 }
local x2 = { x1 }
x1[x2] = x2

local y1 = { 17, 23, 42 }
local y2 = { y1 }
y1[y2] = y2

assert(equal(x1, y1))

local x1 = { 17, 23, 42 }
local x2 = { x1 }
x1[{}] = x2
x1[x2] = x2

local y1 = { 17, 23, 42 }
local y2 = { y1 }
y1[{}] = y2
y1[y2] = y2

assert(equal(x1, y1))

local x1 = {
  [{}] = 17;
  [{}] = 42;
  [{}] = 42;
}
local y1 = {
  [{}] = 17;
  [{}] = 42;
}

assert(not equal(x1, y1))
y1[{}] = 42
assert(equal(x1, y1))

assert(not equal({ 1, 2, 3 }, { 1, 2, 3, 4 }))

local x1 = { { 42 }, { 42 } }
local y2 = { 42 }
local y1 = { y2, y2 }

assert(not equal(x1, y1))
