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

local function test_case(write, read)
  local function test(source)
    local handle = assert(io.open("test.dat", "wb"))
    write(handle, source)
    handle:close()

    if verbose then
      local handle = assert(io.open("test.dat", "rb"))
      io.stdout:write(("-"):rep(60), "\n")
      io.stdout:write(handle:read "*a")
      handle:close()
    end

    local handle = assert(io.open("test.dat", "rb"))
    local result = read(handle)
    handle:close()

    if verbose then
      io.stdout:write(("%s <> %s\n"):format(source, result))
    end

    assert(serializer.equal(source, result))
  end

  test(nil)
  test(false)
  test(true)
  test(3.14)
  test(42)
  test(42.0)
  test("foo")

  -- number
  test(1.7976931348623157e+308) -- DBL_MAX
  test(4.9406564584124654e-324) -- DBL_DENORM_MIN
  test(2.2250738585072014e-308) -- DBL_MIN
  test(2.2204460492503131e-16)  -- DBL_EPSILON

  -- number (minus)
  test(-1.7976931348623157e+308) -- DBL_MAX
  test(-4.9406564584124654e-324) -- DBL_DENORM_MIN
  test(-2.2250738585072014e-308) -- DBL_MIN
  test(-2.2204460492503131e-16)  -- DBL_EPSILON

  -- integer
  test(0x7FFFFFFFFFFFFFFF)
  test(0xFFFFFFFFFFFFFFFF)
  test(-1)
  test(42)

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

  local source = {}
  for i = -64, 64 do
    source[i] = i * i
  end
  test(source)
end

local write_functions = {
  serializer.write;
  function (handle, source)
    handle:write(serializer.encode(source))
  end;
  serializer.write_v1;
  function (handle, source)
    serializer.write_v1(handle, source, true)
  end;
  function (handle, source)
    handle:write(serializer.encode_v1(source))
  end;
  function (handle, source)
    handle:write(serializer.encode_v1(source, true))
  end;
  serializer.write_v2;
  function (handle, source)
    serializer.write_v2(handle, source, 0)
  end;
  function (handle, source)
    serializer.write_v2(handle, source, 1)
  end;
  function (handle, source)
    serializer.write_v2(handle, source, 2)
  end;
  function (handle, source)
    handle:write(serializer.encode_v2(source))
  end;
  function (handle, source)
    handle:write(serializer.encode_v2(source, 0))
  end;
  function (handle, source)
    handle:write(serializer.encode_v2(source, 1))
  end;
  function (handle, source)
    handle:write(serializer.encode_v2(source, 2))
  end;
}

local read_functions = {
  serializer.read;
  function (handle)
    return serializer.decode(handle:read "*a")
  end;
}

for i = 1, #write_functions do
  for j = 1, #read_functions do
    if verbose then
      io.stdout:write(("="):rep(60), "\n")
      io.stdout:write("TEST(", i, ",", j, ")\n")
    end
    test_case(write_functions[i], read_functions[j])
  end
end
