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
 * Class for managing history of the document in the localStorage.
 */
function Backup ($params = {}) {
  var params = this.params = {
    prefix: 'h-item:' + ($params.prefix || 'default') + ':',
    registry: 'h-registry:' + ($params.prefix || 'default'),
    max: 10,
    debug: $params.debug
  }

  var getLastVersionId = () => {
    return registry[registry.length - 1] || null
  }

  var registryText = localStorage[params.registry] || '[]'
  var registry = JSON.parse(registryText).sort()

  this.getLastVersion = () => {
    var version = localStorage[getLastVersionId()] || 'null'
    return JSON.parse(version)
  }

  this.getVersionIdBefore = (versionId) => {
    return registry[registry.indexOf(versionId) - 1] || null
  }

  var registryClear = () => {
    var extra = registry.length - params.max

    if (extra > 0) {
      for (var i = 0; i < extra; i++) {
        delete localStorage[registry[i]]
      }

      registry.splice(0, extra)
    }

    localStorage[params.registry] = JSON.stringify(registry)
  }

  this.removeVersion = (versionId) => {
    var index = registry.indexOf(versionId)

    if (index !== -1) {
      /* Removing from the registry */
      registry.splice(index, 1)
      /* Saving the registry */
      localStorage[params.registry] = JSON.stringify(registry)
      /* Removing version */
      delete localStorage[versionId]
    }
  }

  this.pop = () => {
    if (registry.length === 0) {
      console.log('Versioning: Registry is empty')
      return
    }

    if (registry.length === 1) {
      console.log('Versioning: Registry contains only 1 version')
      return
    }

    delete localStorage[registry.pop()]
    registryClear()

    return this.getLastVersion()
  }

  this.push = (json) => {
    var newVersionId = params.prefix + Date.now()
    var newVersion = JSON.stringify(json)

    localStorage[newVersionId] = newVersion
    registry.push(newVersionId)
    registryClear()
  }
}

export default Backup
