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
 *
 * Formats XML.
 */

 /* eslint-disable */
function createShiftArr (step) {
  var space = '  '

  space = isNaN(parseInt(step))
    ? step
    : new Array(step + 1).join(' ')

  var shift = ['\n']
  for (var ix = 0; ix < 100; ix++) {
    shift.push(shift[ix] + space)
  }
  return shift
}

function Prettify () {
  this.step = '  '
  this.shift = createShiftArr(this.step)
}

Prettify.prototype.xml = function (text, step) {
  var ar = text.replace(/>\s{0,}</g, '><')
    .replace(/</g, '~::~<')
    .replace(/\s*xmlns\:/g, '~::~xmlns:')
    .replace(/\s*xmlns\=/g, '~::~xmlns=')
    .split('~::~'),
    len = ar.length,
    inComment = false,
    deep = 0,
    str = '',
    ix = 0,
    shift = step ? createShiftArr(step) : this.shift

  for (ix = 0; ix < len; ix++) {
    if (ar[ix].search(/<!/) > -1) {
      str += shift[deep] + ar[ix]
      inComment = true

      if (ar[ix].search(/-->/) > -1 || ar[ix].search(/\]>/) > -1 || ar[ix].search(/!DOCTYPE/) > -1) {
        inComment = false
      }
    } else if (ar[ix].search(/-->/) > -1 || ar[ix].search(/\]>/) > -1) {
      str += ar[ix]
      inComment = false
    } else if (/^<\w/.exec(ar[ix - 1]) && /^<\/\w/.exec(ar[ix]) &&
      /^<[\w:\-\.\,]+/.exec(ar[ix - 1]) == /^<\/[\w:\-\.\,]+/.exec(ar[ix])[0].replace('/', '')) {
      str += ar[ix]
      if (!inComment) deep--
    } else if (ar[ix].search(/<\w/) > -1 && ar[ix].search(/<\//) == -1 && ar[ix].search(/\/>/) == -1) {
      str = !inComment ? str += shift[deep++] + ar[ix] : str += ar[ix]
    } else if (ar[ix].search(/<\w/) > -1 && ar[ix].search(/<\//) > -1) {
      str = !inComment ? str += shift[deep] + ar[ix] : str += ar[ix]
    } else if (ar[ix].search(/<\//) > -1) {
      str = !inComment ? str += shift[--deep] + ar[ix] : str += ar[ix]
    } else if (ar[ix].search(/\/>/) > -1) {
      str = !inComment ? str += shift[deep] + ar[ix] : str += ar[ix]
    } else if (ar[ix].search(/<\?/) > -1) {
      str += shift[deep] + ar[ix]
    } else if (ar[ix].search(/xmlns\:/) > -1 || ar[ix].search(/xmlns\=/) > -1) {
      str += shift[deep] + ar[ix]
    } else {
      str += ar[ix]
    }
  }

  return (str[0] == '\n') ? str.slice(1) : str
}

Prettify.prototype.xmlmin = function (text, preserveComments) {
  var str = preserveComments ? text : text
    .replace(/\<![ \r\n\t]*(--([^\-]|[\r\n]|-[^\-])*--[ \r\n\t]*)\>/g, '')
    .replace(/[ \r\n\t]{1,}xmlns/g, ' xmlns')
  return str.replace(/>\s{0,}</g, '><')
}

export default new Prettify()
