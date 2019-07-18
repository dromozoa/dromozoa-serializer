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

local error = error
local pairs = pairs
local type = type
local math_type = math.type
local string_char = string.char

local encoder1 = {}
for v = 0, 255 do
  encoder1[v] = string_char(v)
end

local function write(handle, u, dict, max, string_dictionary)
  if u == nil then
    handle:write "\0\0"
  else
    local t = type(u)
    if t == "boolean" then
      if u then
        handle:write "\0\1"
      else
        handle:write "\0\2"
      end
    elseif t == "number" then
      if math_type and math_type(u) == "integer" then
        handle:write("\255\4", ("%20d "):format(u))
      else
        handle:write("\255\5", ("%24.17g "):format(u))
      end
    elseif t == "string" then
      if string_dictionary then
        local ref = dict[u]
        if ref then
          if ref < 256 then
            handle:write("\0", encoder1[ref])
          elseif ref < 4096 then
            local b = ref % 256
            local a = (ref - b) / 256
            handle:write(encoder1[a], encoder1[b])
          else
            handle:write("\255\1", ("%20d "):format(ref))
          end
        else
          local size = #u
          if size < 256 then
            handle:write("\128", encoder1[size], u)
          elseif size < 4096 then
            local b = size % 256
            local a = (size - b) / 256 + 128
            handle:write(encoder1[a], encoder1[b], u)
          else
            handle:write("\255\3", ("%20d "):format(size), u)
          end
          max = max + 1
          dict[u] = max
        end
      else
        local size = #u
        if size < 256 then
          handle:write("\64", encoder1[size], u)
        elseif size < 4096 then
          local b = size % 256
          local a = (size - b) / 256 + 64
          handle:write(encoder1[a], encoder1[b], u)
        else
          handle:write("\255\2", ("%20d "):format(size), u)
        end
      end
    elseif t == "table" then
      local ref = dict[u]
      if ref then
        if ref < 256 then
          handle:write("\0", encoder1[ref])
        elseif ref < 4096 then
          local b = ref % 256
          local a = (ref - b) / 256
          handle:write(encoder1[a], encoder1[b])
        else
          handle:write("\255\1", ("%20d "):format(ref))
        end
      else
        handle:write "\255\6"

        max = max + 1
        dict[u] = max

        local written = {}
        for i = 1, #u do
          max = write(handle, u[i], dict, max, string_dictionary)
          written[i] = true
        end

        handle:write "\255\7"

        for k, v in pairs(u) do
          if not written[k] then
            max = write(handle, k, dict, max, string_dictionary)
            max = write(handle, v, dict, max, string_dictionary)
          end
        end

        handle:write "\255\7"
      end
    else
      error("unsupported type " .. t)
    end
  end

  return max
end

local function write(handle, u, dict, max, string_dictionary, mode)
  if u == nil then
    handle:write "\n1 0"
  else
    local t = type(u)
    if t == "boolean" then
      if u then
        handle:write "\n1 1"
      else
        handle:write "\n1 2"
      end
    elseif t == "number" then
      if math_type and math_type(u) == "integer" then
        handle:write("\n2 ", u)
      else
        handle:write("\n3 ", ("%.17g"):format(u))
      end
    elseif t == "string" then
      if string_dictionary + mode < 2 then
        handle:write("\n4 ", #u, ":", u)
      else
        local ref = dict[u]
        if ref then
          handle:write("\n1 ", ref)
        else
          handle:write("\n5 ", #u, ":", u)
          max = max + 1
          dict[u] = max
        end
      end
    elseif t == "table" then
      local ref = dict[u]
      if ref then
        handle:write("\n1 ", ref)
      else
        local size = #u
        handle:write("\n6 ", size)
        max = max + 1
        dict[u] = max

        local written = {}
        for i = 1, size do
          max = write(handle, u[i], dict, max, string_dictionary, 0)
          written[i] = true
        end

        for k, v in pairs(u) do
          if not written[k] then
            max = write(handle, k, dict, max, string_dictionary, 1)
            max = write(handle, v, dict, max, string_dictionary, 0)
          end
        end

        handle:write "\n7 0"
      end
    else
      error("unsupported type " .. t)
    end
  end

  return max
end

return function (handle, u, string_dictionary)
  if not string_dictionary then
    string_dictionary = 0
  end
  local dict = { [true] = 1, [false] = 2 }
  handle:write "2"
  write(handle, u, dict, 2, string_dictionary, 0)
  handle:write "\n"
end
