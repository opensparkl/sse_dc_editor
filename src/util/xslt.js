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
 * XSLT transformation functions.
 */
import parser from './parser'
import axios from 'axios'

var xsls = {}
var config = {
  debug: true
}

/**
 * Returns the compiled stylesheet supplied in sourceNode.
 * IE version compiles xsl and returns an ActiveX processor.
 */
function compileXSL (sourceNode) {
  if (document.implementation && document.implementation.createDocument) {
    var xsl = new window.XSLTProcessor()
    xsl.importStylesheet(sourceNode)

    return xsl
  } else {
    throw new Error('XSLT: ActiveX and IE is not supported')
  }
}

/**
 * Returns the result of transforming the supplied XML node
 * using the compiled XSL stylesheet.
 * The optional params object is used to set the XSLT parameters if present.
 */
function transformXML (xml, xsl, params) {
  if (window.ActiveXObject || 'ActiveXObject' in window) {
    throw new Error('XSLT: IE transformXSL not supported')
  }

  xsl.clearParameters()

  if (params && typeof params === 'object') {
    for (var i in params) {
      if (params.hasOwnProperty(i)) {
        xsl.setParameter(null, i, params[i])
      }
    }
  }
  var result = xsl.transformToFragment(xml, parser.document)

  return result
}

function transform (xslName, xml, callback, id) {
  var params = id ? {id} : null
  var xsl = xsls[xslName]

  if (xsl) {
    var result = transformXML(xml, xsl.xsl, params)
    if (callback) {
      callback(result)
    }
  } else {
    throw new Error(`XSL ${xslName} not found.`)
  }
};

var load = (name, url) => {
  var startedAt = Date.now()
  return new Promise((resolve) => {
    axios.get(url)
      .catch(() => resolve())
      .then(response => {
        try {
          console.log('XSLT: Compiling ' + url)

          var xml = parser.string2Xml(response.data)
          var xsl = compileXSL(xml)

          if (config.debug) {
            console.log(`XSLT: Ready (${Date.now() - startedAt}ms) ${url}`)
          }

          resolve({name, url, xsl})
        } catch (e) {
          console.warn(e)
          resolve()
        }
      })
  })
}

function use (sources, params = {}) {
  config = params || {}

  let promises = []

  if (typeof sources === 'string') {
    sources = {
      default: sources
    }
  }

  if (config.debug) {
    console.log(`XSLT: Loading...`)
  }

  for (var key in sources) {
    promises.push(load(key, sources[key]))
  }

  Promise.all(promises).then(values => {
    xsls = values.reduce((set, value) => {
      if (value) set[value.name] = value
      return set
    }, {})
  })
}

export default {
  transform,
  use
}
