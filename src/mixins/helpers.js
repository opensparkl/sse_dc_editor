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
 * Mixin with various helper functions.
 */
import { mapGetters } from 'vuex'
import tree from '../util/tree'
import xslt from '../util/xslt'
import util from '../util'
import config from '../config'

export default {
  computed: {
    ...mapGetters([
      'nodes'
    ])
  },
  methods: {
    identifyErrors (xml, callback) {
      var time = Date.now()

      xslt.transform('validation', xml, errors => {
        var items = errors.firstElementChild
          .querySelectorAll('warning, error')

        var counts = {
          total: 0,
          warning: 0,
          error: 0
        }

        var dict = {}

        for (var i = 0; i < items.length; i++) {
          var item = items[i]
          var type = item.nodeName

          counts.total++
          counts[type]++

          var id = item.getAttribute('ref')
          var node = this.nodes[id]
          var name = node.attr.name
          var attr = {}

          if (!node) {
            console.warn('Warning! This node does not exist:', id)
          }

          // Needs to be in 2 steps as the parent of prop can be reply
          if (node.tag === 'grant' || node.tag === 'prop') {
            id = node.parent_id
          }

          if (util.type.isReply(node)) {
            id = node.parent_id
          }

          attr = util.attrsFor(item)

          if (id) {
            attr.errorType = type
            attr.nodeName = name

            dict[id] = dict[id] || []
            dict[id].push(attr)
          }
        }

        if (config.debug) {
          console.log(`XSLT: Validation (${Date.now() - time}ms)`)
        }

        callback(dict, counts)
      })
    },

    renderValidationErrorMessage (counts) {
      if (counts.total === 0) {
        this.$notify({
          title: 'Validation',
          text: 'No errors or warnings found.',
          type: 'success'
        })
      } else if (counts.error > 0) {
        this.$notify({
          title: 'Validation',
          text: `${counts.error} error(s) and ${counts.warning} warning(s) found.`,
          type: 'error',
          duration: 600000
        })
      } else if (counts.warning > 0) {
        this.$notify({
          title: 'Validation',
          text: `${counts.warning} warning(s) found.`,
          type: 'warn'
        })
      }
    },

    validate (callback) {
      var xml = tree.xml(this.nodes)

      this.identifyErrors(xml, (errors, counts) => {
        this.$store.commit('setErrors', errors)
        this.renderValidationErrorMessage(counts)

        if (typeof callback === 'function') {
          callback(errors, counts, xml)
        }
      })
    }
  }
}
