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

local function encode_value(v)
  local t = type(v)
  if t == "number" then
    return ("%.17g"):format(v)
  elseif t == "boolean" then
    if v then
      return "true"
    else
      return "false"
    end
  elseif t == "string" then
    return ("%q"):format(v)
  else
    error("invalid type " .. t)
  end
end

local keys = {
  "全国地方公共団体コード";
  "（旧）郵便番号";
  "郵便番号";
  "都道府県名";
  "市区町村名";
  "町域名";
  "都道府県名";
  "市区町村名";
  "町域名";
  "一町域が二以上の郵便番号で表される場合の表示";
  "小字毎に番地が起番されている町域の表示";
  "丁目を有する町域の場合の表示";
  "一つの郵便番号で二以上の町域を表す場合の表示";
  "更新の表示";
  "変更理由";
}

local codeset = {}

for line in io.lines() do
  local data = { assert(line:match([[^(%d+),"(%d+) *","(%d+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)",(%d),(%d),(%d),(%d),(%d),(%d)]] .. "\r$")) }
  assert(#data == 15)
  for i = 10, 13 do
    data[i] = data[i] == "1"
  end
  for i = 14, 15 do
    data[i] = assert(tonumber(data[i]))
  end
  for i = 1, 15 do
    data[keys[i]] = data[i]
  end
  local n = #dataset + 1
  dataset[n] = data

  local code = data[1]
  local codes = codeset[code]
  if codes then
    codes[#codes + 1] = n
  else
    codeset[code] = { n }
  end
end

local n = #dataset
local m = 65536

io.write "local _ = {}\n"
io.write "local f\n"

for i = 1, n, m do
  io.write "f = function ()\n"
  for j = i, math.min(n, i + m - 1) do
    io.write("_[", j, "]={")
    local data = dataset[j]
    for k, v in pairs(data) do
      io.write("[", encode_value(k), "]=", encode_value(v), ";")
    end
    io.write("}\n")
  end
  io.write "end\n"
  io.write "f()\n"
end

for code, list in pairs(codeset) do
  local n = #list
  io.write("_[", encode_value(code), "]={}\n")
  io.write "f = function ()\n"
  for i = 1, n do
    io.write("_[", encode_value(code), "]=_[", list[i], "]\n")
  end
  io.write "end\n"
  io.write "f()\n"
end

io.write "return _\n"
