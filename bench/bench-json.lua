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

local json_module, source_filename, result_filename, buffer_size = ...

local json = require(json_module)

local timer = unix.timer()

timer:start()
local source = assert(loadfile(source_filename))()
timer:stop()
print("loadfile", timer:elapsed())

local handle = io.open(result_filename, "wb")
if buffer_size then
  handle:setvbuf("full", tonumber(buffer_size))
end
timer:start()
handle:write(json.encode(source))
timer:stop()
handle:close()
print("json.encode", timer:elapsed())

local handle = io.open(result_filename, "rb")
timer:start()
local result = json.decode(handle:read "*a")
timer:stop()
handle:close()
print("json.decode", timer:elapsed())
