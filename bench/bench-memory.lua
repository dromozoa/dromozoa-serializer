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

local source_filename = ...

local timer = unix.timer()

timer:start()
local source = assert(loadfile(source_filename))()
timer:stop()
print("loadfile", timer:elapsed())

collectgarbage()
collectgarbage()
local gc1 = collectgarbage "count"

timer:start()
local encoded = serializer.encode(source, true)
timer:stop()

local gc2 = collectgarbage "count"

print("encode", timer:elapsed(), gc2 - gc1)

source = nil

collectgarbage()
collectgarbage()
local gc1 = collectgarbage "count"

timer:start()
local decoded = serializer.decode(encoded)
timer:stop()

local gc2 = collectgarbage "count"

print("decode", timer:elapsed(), gc2 - gc1)
