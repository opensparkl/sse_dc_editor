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
 * Functions for importing Sparkl mixes from desktop and Sparkl backend.
 */
import config from '../config'
import util from '../util'
import Tree from '../util/tree'
import api from '../api'

const mimes = config.import.mimeTypes

var importFromFile = function (file, callback) {
  if (file) {
    var reader = new FileReader()
    var filetype = file.type

    if (filetype && mimes.indexOf(file.type) === -1) {
      var text = `You are trying to import a file with
        <span class="un">${filetype}</span> MIME-type which is not
        supported. Only <span class="un">text/xml</span> files can
        be imported.`

      return callback({
        type: 'error',
        duration: 6000,
        title: 'Parsing error',
        text
      })
    }

    reader.onerror = () => {
      return callback({
        type: 'error',
        duration: 600000,
        title: 'File system error',
        text: 'Failed to open the file.'
      })
    }

    reader.onload = () => {
      var text = reader.result
      var xml = util.parser.string2Xml(text)
      var error = util.parser.parsingErrorXML(xml)

      if (error) {
        return callback({
          type: 'error',
          title: 'Parsing error',
          text: error
        })
      }

      var json = util.parser.structXml2Json(xml)

      Tree.populate(json, (error, nodes) => {
        if (error) {
          return callback({
            type: 'error',
            title: error.type,
            text: error.message
          })
        }

        callback(null, nodes)
      })
    }

    reader.readAsText(file)
  }
}

var importFromSparkl = (source, callback) => {
  api.source.get(source.folder)
    .then(response => {
      var json = util.parser.structXml2Json(response.data)
      Tree.populate(json, callback)
    })
    .catch(error => {
      callback(error)
    })
}

export {
  importFromFile,
  importFromSparkl
}
