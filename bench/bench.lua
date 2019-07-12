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

local source_filename, result_filename, write_option, buffer_size = ...

local timer = unix.timer()

local write = serializer.write
if write_option == "write_v1" then
  write = serializer.write_v1
elseif write_option == "write_v1_string_dictionary" then
  write = function (handle, source)
    return serializer.write_v1(handle, source, true)
  end
end

timer:start()
local source = assert(loadfile(source_filename))()
timer:stop()
print("loadfile", timer:elapsed())

local handle = io.open(result_filename, "wb")
if buffer_size then
  handle:setvbuf("full", tonumber(buffer_size))
end

timer:start()
write(handle, source)
timer:stop()
handle:close()
print("write", timer:elapsed())

local handle = io.open(result_filename, "rb")
timer:start()
local result = serializer.read(handle)
timer:stop()
handle:close()
print("read", timer:elapsed())
