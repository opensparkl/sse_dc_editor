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
 * Application configuration, contains static information about icon,
 * supported mime-types and other params.
 */
import icons from './icons'
import components from './components'
import layouts from './layouts'

export default {
  icons,
  layouts,
  components,
  version: '2.0.1',
  debug: false,
  codemirror: {
    tabSize: 2,
    alignCDATA: true,
    foldGutter: true,
    lineNumbers: true,
    lineWrapping: true,
    mode: 'text/plain',
    gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
  },
  docsUrl: 'http://docs.sparkl.com?contextId=',
  xsl: {
    validation: './static/xsl/browser_main.xsl',
    transform: './static/xml2text.xsl'
  },
  storage: {
    lsPrefix: 'sparkl:store:'
  },
  import: {
    mimeTypes: [
      'text/xml',
      'application/xml'
    ]
  },
  mimeTypes: [
    'application/javascript',
    'application/json',
    'application/xml',
    'text/javascript',
    'text/plain',
    'text/xml',
    'text/x-markdown',
    'text/x-yaml',
    'text/x-erlang',
    'text/x-python'
  ]
}

export {
  icons,
  layouts,
  components
}
