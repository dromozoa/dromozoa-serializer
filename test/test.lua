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

io.write(("="):rep(60), "\n")
serializer.serialize(io.stdout, 3.14)
io.write(("="):rep(60), "\n")
serializer.serialize(io.stdout, 42)
io.write(("="):rep(60), "\n")
serializer.serialize(io.stdout, true)
io.write(("="):rep(60), "\n")
serializer.serialize(io.stdout, "foo")
io.write(("="):rep(60), "\n")
serializer.serialize(io.stdout, {
  foo = 42;
  bar = "baz";
})

io.write(("="):rep(60), "\n")
local x = { name = "x"; }
local y = { name = "y";  to = x }
local z = { name = "z";  to = y }
x.to = z
serializer.serialize(io.stdout, x)

