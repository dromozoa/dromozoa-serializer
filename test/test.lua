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

local verbose = os.getenv "VERBOSE" == "1"

local handle
if verbose then
  handle = io.stdout
else
  handle = assert(io.open("/dev/null", "wb"))
end

handle:write(("="):rep(60), "\n")
serializer.save_handle(handle, 3.14)
handle:write(("="):rep(60), "\n")
serializer.save_handle(handle, 42)
handle:write(("="):rep(60), "\n")
serializer.save_handle(handle, true)
handle:write(("="):rep(60), "\n")
serializer.save_handle(handle, "foo")
handle:write(("="):rep(60), "\n")
serializer.save_handle(handle, {
  foo = 42;
  bar = "baz";
})

if not verbose then
  handle:close()
end
handle = nil

local x = { name = "x"; }
local y = { name = "y"; }
local z = { name = "z"; }
x.to = y
y.to = z
z.to = x

local handle = assert(io.open("test1.dat", "wb"))
serializer.save_handle(handle, x)
handle:close()

local handle = assert(io.open("test1.dat", "rb"))
local data = serializer.load_handle(handle)
handle:close()

assert(data.name == "x")
assert(data.to.name == "y")
assert(data.to.to.name == "z")
assert(data.to.to.to.name == "x")

local handle = assert(io.open("test2.dat", "wb"))
serializer.save_handle(handle, {
  foo = false;
  bar = 42;
  baz = { {1}, {2}, {3}, {4}, "    1234    " };
  qux = {{{{}}}};
})
handle:close()

local handle = assert(io.open("test2.dat", "rb"))
local data = serializer.load_handle(handle)
handle:close()
assert(data.foo == false)
assert(data.bar == 42)
assert(data.baz[1][1] == 1)
assert(data.baz[2][1] == 2)
assert(data.baz[3][1] == 3)
assert(data.baz[4][1] == 4)
assert(data.baz[5] == "    1234    ")
assert(#data.qux == 1)
assert(#data.qux[1] == 1)
assert(#data.qux[1][1] == 1)
assert(#data.qux[1][1][1] == 0)

os.remove "test1.dat"
os.remove "test2.dat"
