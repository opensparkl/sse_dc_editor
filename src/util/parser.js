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
 * Parser library transforms xml|struct|text to xml|struct|text
 */
var XMLParser
var xmlDocument = document.implementation.createDocument('', '', null)

if (window.DOMParser) {
  XMLParser = function (xmlStr) {
    return (new window.DOMParser()).parseFromString(xmlStr, 'text/xml')
  }
} else if (typeof ActiveXObject !== 'undefined' || 'ActiveXObject' in window) {
  XMLParser = function (xmlStr) {
    var xmlDoc = new window.ActiveXObject('Microsoft.XMLDOM')
    xmlDoc.async = 'false'
    xmlDoc.loadXML(xmlStr)
    return xmlDoc
  }
}

var xpath = function (xml, path) {
  return xmlDocument.evaluate(path, xml, null,
      window.XPathResult.ANY_TYPE, null)
}

var string2Xml = function (string) {
  var xml = XMLParser(string)
  return xml.firstElementChild
}

var xml2String = function (xml) {
  return new window.XMLSerializer().serializeToString(xml)
}

var string2Array = function (string, separator = ' ') {
  if (Array.isArray(string)) return string
  if (typeof string !== 'string') return []

  return string.split(separator).filter(s => s.trim() !== '')
}

var structJson2Xml = function (json, params) {
  params = params || {}
  if (typeof json === 'object') {
    var xml = xmlDocument.createElement(json.tag)

    if (typeof json.attr === 'object') {
      var ignored = params.ignoreAttr || []
      var needsToIgnore = ignored.length > 0

      /* Forcing "name" attribute to be ALWAYS first in xml */
      if (json.attr.name) {
        xml.setAttribute('name', json.attr.name || '')
      }

      for (var j in json.attr) {
        if (json.attr.hasOwnProperty(j)) {
          var value = json.attr[j]

          if (j === 'name') continue
          /**
           * Skip if argument is an empty string or attr is in ignore list
           */
          var skipEmpty = json.tag === 'prop'
            ? false
            : (!value && !params.emptyAttr)
          var skipIgnored = needsToIgnore && ignored.indexOf(j) !== -1

          if (skipEmpty || skipIgnored) {
            continue
          }
          /**
           * Skip if argument is an empty array
           */
          if (Array.isArray(value) && value.length === 0) {
            continue
          }

          xml.setAttribute(j, value)
        }
      }
    }

    if (Array.isArray(json.content)) {
      json.content.forEach((item, i) => {
        var childNode = null

        if (typeof item === 'string') {
          childNode = item.indexOf(']]>') === -1
            ? xmlDocument.createCDATASection(item)
            : xmlDocument.createTextNode(item)
        } else {
          childNode = structJson2Xml(item, params)
        }

        xml.appendChild(childNode)
      })
    }
  }
  return xml
}

var isTextNode = (node) => {
  return node.nodeType === window.Node.TEXT_NODE ||
    node.nodeType === window.Node.CDATA_SECTION_NODE
}

var structXml2Json = (xml, params = {}) => {
  var excudeAttrs = string2Array(params.excludeAttributes)
  var excludeTags = string2Array(params.excludeTags)

  if (typeof xml === 'string') {
    xml = XMLParser(xml).firstElementChild
  }

  var json = {tag: xml.nodeName, attr: {}, content: []}

  if (xml.attributes) {
    for (let i = 0, ln = xml.attributes.length; i < ln; i++) {
      var attr = xml.attributes[i]
      var name = attr.nodeName

      if (excudeAttrs.indexOf(name) === -1) {
        json.attr[name] = attr.nodeValue
      }
    }
  }

  if (xml.childNodes) {
    for (let i = 0, ln = xml.childNodes.length; i < ln; i++) {
      var node = xml.childNodes[i]
      var isExcluded = excludeTags.indexOf(node.nodeName) !== -1

      if (!isExcluded) {
        if (node.nodeType === window.Node.ELEMENT_NODE) {
          var child = structXml2Json(node)
          if (child) {
            json.content.push(child)
          }
          continue
        }

        if (isTextNode(node)) {
          var value = node.nodeValue// .trim();

          if (value.length > 0) {
            json.value = value
          }
        }
      }
    }
  }

  return json
}

var parsingErrorXML = (xmlNode) => {
  var parsererror = xmlNode.querySelector('parsererror')

  if (parsererror) {
    var div = xmlNode.querySelector('div')
    var message = div ? div.textContent : 'error'

    return 'Parsing ' + message.trim() + '.'
  }

  return null
}

module.exports = {
  string2Xml,
  xml2String,
  structJson2Xml,
  structXml2Json,
  xpath,
  parsingErrorXML,
  document: xmlDocument
}
