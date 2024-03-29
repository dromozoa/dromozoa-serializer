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

local source_filename, result_filename, write_option, read_option, buffer_size = ...

if ubench then
  assert(unix.sched_setaffinity(unix.getpid(), { 3 }))
  assert(unix.sched_setscheduler(unix.getpid(), unix.SCHED_FIFO, {
    sched_priority = unix.sched_get_priority_max(unix.SCHED_FIFO) - 1;
  }))
end

local timer = unix.timer()

local write = serializer.write
if write_option == "write_v1" then
  write = serializer.write_v1
elseif write_option == "write_v1_string_dictionary" then
  write = function (handle, source)
    return serializer.write_v1(handle, source, true)
  end
elseif write_option == "encode_v1" then
  write = function (handle, source)
    handle:write(serializer.encode_v1(source))
  end
elseif write_option == "encode_v1_string_dictionary" then
  write = function (handle, source)
    handle:write(serializer.encode_v1(source, true))
  end
elseif write_option == "write_v2" then
  write = serializer.write_v2
elseif write_option == "write_v2_string_dictionary_all" then
  write = function (handle, source)
    return serializer.write_v2(handle, source, 2)
  end
elseif write_option == "write_v2_string_dictionary_key" then
  write = function (handle, source)
    return serializer.write_v2(handle, source, 1)
  end
elseif write_option == "encode_v2" then
  write = function (handle, source)
    handle:write(serializer.encode_v2(source))
  end
elseif write_option == "encode_v2_string_dictionary_all" then
  write = function (handle, source)
    handle:write(serializer.encode_v2(source, 2))
  end
elseif write_option == "encode_v2_string_dictionary_key" then
  write = function (handle, source)
    handle:write(serializer.encode_v2(source, 1))
  end
end

local read = serializer.read
if read_option == "decode" then
  read = function (handle)
    return serializer.decode(handle:read "*a")
  end
end

timer:start()
local source = assert(loadfile(source_filename))()
timer:stop()

if ubench then
  assert(unix.munlockall())
end

print("loadfile", timer:elapsed())

local handle = io.open(result_filename, "wb")
if buffer_size then
  handle:setvbuf("full", tonumber(buffer_size))
end

if ubench then
  assert(unix.mlockall(unix.bor(unix.MCL_CURRENT, unix.MCL_FUTURE)))
end

timer:start()
write(handle, source)
timer:stop()

if ubench then
  assert(unix.munlockall())
end

handle:close()
print("write", timer:elapsed())

local handle = io.open(result_filename, "rb")

if ubench then
  assert(unix.mlockall(unix.bor(unix.MCL_CURRENT, unix.MCL_FUTURE)))
end

timer:start()
local result = read(handle)
timer:stop()

if ubench then
  assert(unix.munlockall())
end

handle:close()
print("read", timer:elapsed())
