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
local equal = require "test.equal"

local verbose = os.getenv "VERBOSE" == "1"

local function test_case(write)
  local function test(source)
    local handle = assert(io.open("test.dat", "wb"))
    write(handle, source)
    handle:close()

    if verbose then
      local handle = assert(io.open("test.dat", "rb"))
      io.stdout:write(("="):rep(60), "\n")
      io.stdout:write(handle:read "*a")
      handle:close()
    end

    local handle = assert(io.open("test.dat", "rb"))
    local result = serializer.read(handle)
    handle:close()

    assert(equal(source, result))
  end

  test(nil)
  test(false)
  test(true)
  test(3.14)
  test(42)
  test(42.0)
  test("foo")

  local x = { name = "x"; }
  local y = { name = "y"; }
  local z = { name = "z"; }
  x.to = y
  y.to = z
  z.to = x
  test(x)

  test {
    foo = false;
    bar = 42;
    baz = { {1}, {2}, {3}, {4}, "    1234    " };
    qux = {{{{}}}};
  }

  test {
    [1] = true;
    [2] = false;
    [3] = nil;
    [4] = 42;
    foo = true;
    bar = false;
    baz = nil;
    qux = 42;
  }

  test {
    [{name="foo"}] = {42};
    [{name="bar"}] = {69};
  }
end

-- test_case(serializer.write)
-- test_case(function (handle, source) serializer.write(handle, source, true) end)
test_case(serializer.write_v2)
