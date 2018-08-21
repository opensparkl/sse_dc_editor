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
 * CodeMirror plugin for showing invisible characters (\t, \t, \s)
 */
const textColor = '#c8d2d7'

const showInvisibles = (CodeMirror) => {
  CodeMirror.defineOption('showInvisibles', false, (cm, val, prev) => {
    let Count = 0
    const Maximum = cm.getOption('maxInvisibles') || 16

    if (prev === CodeMirror.Init) { prev = false }

    if (prev && !val) {
      cm.removeOverlay('invisibles')
      return rm()
    }

    if (!prev && val) {
      add(Maximum)

      cm.addOverlay({
        name: 'invisibles',
        token: function nextToken (stream) {
          let spaces = 0
          let symbol = stream.peek()
          let peek = symbol === ' '

          if (peek) {
            while (peek && spaces < Maximum) {
              ++spaces

              stream.next()
              peek = stream.peek() === ' '
            }

            let ret = 'whitespace whitespace-' + spaces

            /*
            * styles should be different
            * could not be two same styles
            * beside because of this check in runmode
            * function in `codemirror.js`:
            *
            * 6624: if (!flattenSpans || curStyle != style) {}
            */
            if (spaces === Maximum) { ret += ' whitespace-rand-' + Count++ }

            return ret
          }

          if (symbol === '\t') {
            stream.next()
            return null
          }

          stream.skipToEnd()
          return 'cm-eol'
        }
      })
    }
  })

  function add (max) {
    const classBase = '.CodeMirror .cm-whitespace-'
    const spaceChar = '·'
    const style = document.createElement('style')

    style.setAttribute('data-name', 'js-show-invisibles')

    let rules = ''
    let spaceChars = ''

    for (let i = 1; i <= max; ++i) {
      spaceChars += spaceChar

      const rule = classBase + i + '::before { content: "' + spaceChars + '";}\n'
      rules += rule
    }

    style.textContent = getStyle() + '\n' + getEOL() + '\n' + rules

    document.head.appendChild(style)
  }

  function rm () {
    const style = document.querySelector('[data-name="js-show-invisibles"]')

    document.head.removeChild(style)
  }

  function getStyle () {
    const style = `
      .cm-whitespace::before {
          position: absolute;
          pointer-events: none;
          color: ${textColor};
      }
    `

    return style
  }

  function getEOL () {
    const style = `
      .CodeMirror-code > div > pre > span::after, .CodeMirror-line > span::after {
          pointer-events: none;
          color: #e1e1e1;
          content: "¬";
      }
    `

    return style
  }
}

export default showInvisibles
