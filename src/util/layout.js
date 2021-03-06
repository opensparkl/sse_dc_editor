/**
 * Copyright 2018 SPARKL Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
var TYPE_INPUT = 'input'

var cleanScheme = function (object) {
  return object.values.map(function (v) {
    if (typeof v === 'string') {
      return {
        name: v,
        type: TYPE_INPUT
      }
    }

    if (typeof v === 'object') {
      if (!v.type) {
        v.type = TYPE_INPUT
      }

      return v
    }
  })
}

export default (scheme) => {
  var localScheme = {}

  for (var i in scheme) {
    if (scheme[i]) {
      localScheme[i] = cleanScheme(scheme[i])
    }
  }

  return localScheme
}
