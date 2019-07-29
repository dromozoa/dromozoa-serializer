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

local unix = require "dromozoa.unix"
local serializer = require "dromozoa.serializer"

local ubench = os.getenv "UBENCH" == "1"

local source_filename, encode_option = ...

if ubench then
  assert(unix.sched_setaffinity(unix.getpid(), { 3 }))
  assert(unix.sched_setscheduler(unix.getpid(), unix.SCHED_FIFO, {
    sched_priority = unix.sched_get_priority_max(unix.SCHED_FIFO) - 1;
  }))
end

local timer = unix.timer()

local encode = serializer.encode
if encode_option == "v1" then
  encode = serializer.encode_v1
elseif encode_option == "v1_all" then
  encode = function (source)
    return serializer.encode_v1(source, true)
  end
elseif encode_option == "v1_none" then
  encode = function (source)
    return serializer.encode_v1(source, false)
  end
elseif encode_option == "v2" then
  encode = serializer.encode_v2
elseif encode_option == "v2_all" then
  encode = function (source)
    return serializer.encode_v2(source, 2)
  end
elseif encode_option == "v2_key" then
  encode = function (source)
    return serializer.encode_v2(source, 1)
  end
elseif encode_option == "v2_none" then
  encode = function (source)
    return serializer.encode_v2(source, 0)
  end
end

timer:start()
local source = assert(loadfile(source_filename))()
timer:stop()
print("loadfile", timer:elapsed())

collectgarbage()
collectgarbage()
local gc1 = collectgarbage "count"

if ubench then
  assert(unix.mlockall(unix.bor(unix.MCL_CURRENT, unix.MCL_FUTURE)))
end

timer:start()
local encoded = encode(source)
timer:stop()

if ubench then
  assert(unix.munlockall())
end

local gc2 = collectgarbage "count"

print("encode", timer:elapsed(), gc2 - gc1)

source = nil

collectgarbage()
collectgarbage()
local gc1 = collectgarbage "count"

if ubench then
  assert(unix.mlockall(unix.bor(unix.MCL_CURRENT, unix.MCL_FUTURE)))
end

timer:start()
local decoded = serializer.decode(encoded)
timer:stop()

if ubench then
  assert(unix.munlockall())
end

local gc2 = collectgarbage "count"

print("decode", timer:elapsed(), gc2 - gc1)
