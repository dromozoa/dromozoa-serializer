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

local source = {
  [1] = true;
  [2] = false;
  [3] = nil;
  [4] = 42;
  foo = true;
  bar = false;
  baz = nil;
  qux = 42;
}

local n = #source
assert(n == 4)

local handle = assert(io.open("test.dat", "wb"))
serializer.write(handle, source)
handle:close()

local handle = assert(io.open("test.dat", "rb"))
local result = serializer.read(handle)
handle:close()
