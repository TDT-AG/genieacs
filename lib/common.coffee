###
# Copyright 2013-2016  Zaid Abdulla
#
# GenieACS is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# GenieACS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with GenieACS.  If not, see <http://www.gnu.org/licenses/>.
#
# This file incorporates work covered by the following copyright and
# permission notice:
#
# Copyright 2013 Fanoos Telecom
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
###

buffer = require 'buffer'
querystring = require 'querystring'

UNDEFINED_TYPE = '[object Undefined]'
NULL_TYPE = '[object Null]'
BOOLEAN_TYPE = '[object Boolean]'
NUMBER_TYPE = '[object Number]'
STRING_TYPE = '[object String]'
ARRAY_TYPE = '[object Array]'
OBJECT_TYPE = '[object Object]'
REGEXP_TYPE = '[object RegExp]'
DATE_TYPE = '[object Date]'


typeOf = (obj) ->
  Object.prototype.toString.call(obj)


exports.endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) isnt -1


exports.startsWith = (str, prefix) ->
  str.substring(0, prefix.length) == prefix


exports.arrayToHash = (arr) ->
  hash = {}
  for i in arr
    hash[i[0]] = i[1]
  return hash


exports.generateDeviceId = (deviceIdStruct) ->
  # Percent escaping function. Escapes everything except alphanumerics and underscore
  esc = (str) ->
    str.replace(/[^A-Za-z0-9_]/g, (chr) ->
      buf = new buffer.Buffer(chr, 'utf8')
      rep = ''
      rep += "%#{b.toString(16).toUpperCase()}" for b in buf
      return rep
    )

  # Guaranteeing globally unique id as defined in TR-069
  if deviceIdStruct['ProductClass']
    return "#{esc(deviceIdStruct['OUI'])}-#{esc(deviceIdStruct['ProductClass'])}-#{esc(deviceIdStruct['SerialNumber'])}"

  return "#{esc(deviceIdStruct['OUI'])}-#{esc(deviceIdStruct['SerialNumber'])}"


exports.parseDeviceId = (deviceId) ->
  parts = deviceId.split('-')
  ret = {oui : querystring.unescape(parts[0])}
  if parts.length == 3
    ret.productClass = querystring.unescape(parts[1])
    ret.serialNumber = querystring.unescape(parts[2])
  else
    ret.serialNumber = querystring.unescape(parts[1])
  return ret


exports.extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj


exports.flattenObject = (object) ->
  newObj = {}
  f = (obj, prefix) ->
    for k, v of obj
      if typeof(v) is 'object'
        f(v, "#{prefix}#{k}.")
      else
        newObj["#{prefix}#{k}"] = v
  f(object, '')
  return newObj


exports.getParamValueFromPath = (obj, path) ->
  pp = path.split('.')
  ref = obj
  try
    for p in pp
      ref = ref[p]
    return ref
  catch err
    return undefined


exports.matchType = (src, dst) ->
  switch typeOf(src)
    when STRING_TYPE
      String(dst)
    when NUMBER_TYPE
      Number(dst)
    when BOOLEAN_TYPE
      v = String(dst).trim().toLowerCase()
      v == 'true' or v == 'on' or v == 'yes' or v == '1'
    else
      dst


pathOverlap = (a, b, start) ->
  if a.length == b.length
    res = 3
  else if a.length > b.length
    res = 2
  else
    res = 1

  for i in [(start ? 0)...Math.min(a.length, b.length)] by 1
    if a[i]?
      if not b[i]?
        res &= 2
      else if a[i] != b[i]
        return 0
    else if b[i]?
      res &= 1

    return 0 if not res

  return res


parsePath = (path) ->
  parts = if path == '' then [] else path.split('.')
  for p, i in parts
    parts[i] = null if p == '*'

  return parts


exports.UNDEFINED_TYPE = UNDEFINED_TYPE
exports.NULL_TYPE = NULL_TYPE
exports.NUMBER_TYPE = NUMBER_TYPE
exports.STRING_TYPE = STRING_TYPE
exports.ARRAY_TYPE = ARRAY_TYPE
exports.OBJECT_TYPE = OBJECT_TYPE
exports.REGEXP_TYPE = REGEXP_TYPE

exports.typeOf = typeOf
exports.pathOverlap = pathOverlap
exports.parsePath = parsePath
