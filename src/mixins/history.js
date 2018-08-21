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
 * Functions for importing Sparkl configuration from various sources.
 */
import tree from '@/util/tree'
import Backup from '@/util/backup'
import { importFromSparkl } from '../helpers/importer'

var randomName = () =>
  'Document-' + Math.random().toString().substr(2, 8)

export default {
  methods: {
    initHistory (params = {}) {
      window.backup = new Backup(params)
    },
    openDocument (source, nodes) {
      /* eslint promise/param-names: "off" */
      return new Promise((resolve0, reject0) => {
        new Promise((resolve, reject) => {
          if (nodes) {
            return resolve(nodes)
          }

          if (source) {
            importFromSparkl(source, (error, nodes) => {
              error
                ? reject(error)
                : resolve(nodes)
            })

            return
          }

          reject0({reason: 'No arguments'})
        })
        .then(actualNodes => {
          this.$store.commit('setSource', source)
          this.$store.commit('setNodes', actualNodes)

          resolve0({source, node: actualNodes})
        })
        .catch(error => {
          reject0(error)
        })
      })
    },
    openLatestDocument () {
      var latest = window.backup.getLastVersion()

      if (latest) {
        if (latest.nodes) {
          if (latest.source) {
            this.$store.commit('setSource', latest.source)
          }

          this.$store.commit('setNodes', latest.nodes)
          return true
        }
      }

      this.createDocument()
      return false
    },
    revertDocument () {
      var json = window.backup.pop()

      if (json) {
        this.$store.commit('setSource', json.source)
        this.$store.commit('setNodes', json.nodes)
      } else {
        this.$notify({
          type: 'warn',
          text: 'History is empty.'
        })
      }
    },
    createDocument (name) {
      var id = tree.Index()

      this.$store.commit('setSource', null)
      this.$store.commit('setNodes', {
        [id]: {
          tag: 'folder',
          attr: {
            id,
            name: name || randomName()
          },
          is_root: true,
          content: []
        }
      })
    }
  }
}
