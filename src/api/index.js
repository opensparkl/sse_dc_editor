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
 * Sparkl API function calls.
 */
import axios from 'axios'
import util from '../util'

var baseURL = JSON.parse(
  localStorage["config"])["router"]["url"]

var server = axios.create({
  baseURL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json'
  }
})

var encodePayload = function (data, headers) {
  var str = []
  for (var p in data) {
    if (data.hasOwnProperty(p) && data[p]) {
      str.push(encodeURIComponent(p) + '=' + encodeURIComponent(data[p]))
    }
  }
  return str.join('&')
}

var createChange = (xml, update) => {
  var remove = ''
  var change = util.parser.xml2String(xml)

  if (update) {
    remove = '<delete name="' + update + '"/>'
  }

  return '<change>' + remove + change + '</change>'
}

var api = {
  baseURL,
  server,
  ping (nodeName) {
    return server.get('sse/ping' + (nodeName ? ('?node=' + nodeName) : ''))
  },
  authenticate (email, password) {
    return server.post('sse_cfg/user', { email, password }, {
      transformRequest: [encodePayload]
    })
  },
  content (path = '') {
    return server.get('sse_cfg/content/' + path)
  },
  object (path = '') {
    return server.get('sse_cfg/object/' + path)
  },
  exists (path = '') {
    return new Promise(resolve => {
      server.get('sse_cfg/object/' + path)
        .then(response => resolve(!!response.data.tag))
        .catch(() => resolve(false))
    })
  },
  objects (objects) {
    if (Array.isArray(objects)) {
      objects = objects.join(' ')
    }
    var uri = encodeURI(objects)
    return server.get(`/sse_cfg/objects?objects=${uri}`)
  },
  info (nodeName = '') {
    return new Promise((resolve, reject) => {
      api.ping(nodeName).then(response => {
        var node = response.data.attr

        if (!nodeName) {
          nodeName = node.node
        }

        server.get('sse/info?node=' + nodeName)
          .then(response => {
            var data = response.data
            var nodes = util.wsSplit(data.attr.nodes)

            nodes.push(data.attr.node)
            nodes.sort()

            resolve({node, nodes, data})
          })
          .catch(reject)
      })
    })
  },
  extension: {
    start (nodeName, extName) {
      return server
        .post(`sse/extension/start?node=${nodeName}&extension=${extName}`)
    },
    stop (nodeName, extName) {
      return server
        .post(`sse/extension/stop?node=${nodeName}&extension=${extName}`)
    },
    info (nodeName, extName) {
      return server
        .post(`sse/extension/info?node=${nodeName}&extension=${extName}`)
    }
  },
  source: {
    get (path, mimeType = 'application/xml') {
      return server.get('sse_cfg/source/' + path, {
        headers: {
          Accept: mimeType
        }
      })
    },
    update (path, xml, foldername) {
      var url = '/sse_cfg/change/' + path
      var change = createChange(xml, foldername)

      return server.post(url, change, {
        headers: {
          'x-sparkl-transform': 'gen_change',
          'Accept': 'application/json',
          'Content-Type': 'application/xml'
        }
      })
    }
  },
  service: {
    start (object) {
      return server.post(`sse_svc/start/${object}`)
    },
    stop (object) {
      return server.post(`sse_svc/stop/${object}`)
    },
    stopAll (ids) {
      var promises = ids.map(id => {
        return api.service.stop(id)
      })

      return Promise.all(promises)
    },
    status (object) {
      return server.get(`sse_svc/status/${object}`)
    },
    list (object = '') {
      return new Promise((resolve, reject) => {
        server.get('sse_svc/status/' + object)
          .then(response => {
            var services = response.data.attr.services

            if (services.length === 0) {
              return resolve([])
            }

            api.objects(services)
              .then(response => resolve(response.data.content))
              .catch(reject)
          })
          .catch(reject)
      })
    }
  },
  license: {
    upload (node, text) {
      return server.post('sse_license/license?node=' + node, text)
    }
  },
  user: {
    self () {
      return server.get('sse_cfg/user')
    },
    list () {
      return server.get('sse_cfg/users')
    },
    delete (id) {
      return server.delete('sse_cfg/user/' + id)
    }
  }
}

export default api
