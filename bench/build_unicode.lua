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

local dataset = {}

for line in io.lines() do
  local data = {}
  local i = 0
  for item in line:gmatch "[^;]*" do
    data[#data + 1] = item
  end
  assert(#data == 15)
  dataset[#dataset + 1] = data
end

io.write "return {\n"
for i = 1, #dataset do
  io.write "{"
  local data = dataset[i]
  for j = 1, #data do
    io.write(("%q;"):format(data[j]))
  end
  io.write "};\n"
end
io.write "}\n"
