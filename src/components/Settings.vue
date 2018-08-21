<!--
  Copyright 2018 SPARKL Limited

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<template>
  <div>
    <button
      class="button full-width with-icon"
      @click="undo">
      <i class="fa fa-fw fa-undo"></i>
      Undo Last Action
    </button>
    <button
      class="button full-width with-icon"
      @click="restore">
      <i class="fa fa-fw fa-clipboard"></i>
      Open document
    </button>
    <button
      class="button full-width with-icon"
      @click="save">
      <i class="fa fa-fw fa-download"></i>
      Save document
    </button>
    <button
      v-if="source"
      class="button full-width with-icon"
      @click="update">
      <i class="fa fa-fw fa-cloud"></i>
      Update existing
    </button>
    <button
      class="button full-width with-icon"
      @click="validate()">
      <i class="fa fa-fw fa-filter"></i>
      Validate
    </button>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import tree from '../util/tree'
import api from '../api'
import helpers from '../mixins/helpers'
import history from '../mixins/history'

var readableError = (error) => {
  if (error.response.data) {
    var data = error.response.data

    if (data.attr) {
      var attr = data.attr
      var message = ''

      for (var i in attr) {
        message += i + ': ' + attr[i] + '<br>'
      }

      return message
    }
  }

  return ''
}

export default {
  mixins: [helpers, history],
  computed: {
    ...mapGetters([
      'nodes',
      'source',
      'root',
      'selected'
    ])
  },
  created () {

  },
  methods: {
    undo () {
      window.backup.skipSave = true
      this.revertDocument()
    },

    save () {
      this.$modal.show('export')
    },

    restore () {
      this.$modal.show('import')
    },

    stopServices (foldername, path) {
      return new Promise(resolve => {
        api.service.list(path).then(services => {
          if (services.length > 0) {
            var names = services.map(v => v.attr.name).join(', ')
            var ids = services.map(v => v.attr.id)
            var ln = services.length
            var plural = ln > 1 ? 's' : ''
            var text = `You are about to replace ${foldername} folder which
              contains ${ln} running service${plural}.
              Are you sure you want to stop service${plural} <b>${names}</b>?`

            this.$modal.show('dialog', {
              title: 'Update',
              text,
              buttons: [
                { title: 'Cancel' },
                {
                  title: 'Stop and update',
                  handler: () => {
                    api.service.stopAll(ids).then(() => {
                      let text = `Stopped ${services.length} services (${names})`

                      this.$notify({
                        title: 'Update',
                        text,
                        type: 'warn'
                      })
                      resolve()
                    })

                    this.$modal.hide('dialog')
                  }
                }
              ]
            })
          } else {
            resolve()
          }
        })
          .catch(resolve)
      })
    },

    update () {
      this.validate((list, counts) => {
        if (counts.error > 0) {
          return this.$notify({
            title: 'Update',
            text: 'Please fix all errors before deploying',
            type: 'error',
            duration: 600000
          })
        }

        var xml = tree.xml(this.nodes, null, {
          ignoreAttr: 'id'
        })

        if (this.source) {
          const { folder } = this.source
          const chunks = folder.split(/\/+/g).filter(v => v)
          const foldername = chunks.pop()

          const parent = chunks.join('/') + '/'

          this.stopServices(foldername, folder).then(() => {
            api.source.update(parent, xml, foldername)
                .then(response => {
                  this.$notify({
                    title: 'Update',
                    text: 'Successfully updated',
                    type: 'success'
                  })
                })
                .catch(error => {
                  var attributes = readableError(error)
                  var message = 'Failed to update ' + foldername

                  if (attributes) {
                    message += '<br><br>' + attributes
                  }

                  this.$notify({
                    type: 'error',
                    title: 'Update error',
                    text: message,
                    duration: 600000
                  })
                })
          })
        } else {
          this.$notify({
            title: 'Update',
            text: 'Nowhere to deploy',
            type: 'error',
            duration: 600000
          })
        }
      })
    }
  }
}
</script>
