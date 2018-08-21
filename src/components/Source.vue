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
  <modal
    name="source"
    :class="{ error }"
    classes="v--modal modal-source"
    :width="900"
    :height="500"
    :resizable="true"
    :adaptive="true"
    :min-width="300"
    :min-height="200"
    @before-open="beforeOpen"
    @before-close="beforeClose">
    <CodeEditor
      v-model="code"
      :options="options"
      @change="onEditorChange"/>
    <div
      v-if="error"
      class="error-message-overflow">
      <span>{{error}} Do you want to close the window and restore previous version?</span>
      <span class="error-message-answers">
        <span
          class="an-option"
          @click.stop="forceClose">Close</span>
      </span>
    </div>
  </modal>
</template>
<script>
import CodeEditor from './CodeEditor'
import { mapGetters } from 'vuex'
import util from '../util'
import xslt from '../util/xslt'
import Tree from '../util/tree'

export default {
  name: 'SourceModal',
  components: {
    CodeEditor
  },
  data () {
    return {
      options: {
        mode: 'text/xml'
      },
      cache: '',
      code: '',
      error: false
    }
  },
  methods: {
    beforeOpen (event) {
      if (this.selectedId) {
        var xml = Tree.xml(this.nodes, this.selectedId, {
          ignoreAttr: ['id']
        })

        xslt.transform('transform', xml, fragment => {
          var text = fragment.textContent

          this.cache = text
          this.code = text
        })
      }
    },

    forceClose () {
      this.code = this.cache
      this.error = null
      this.$modal.hide('source')
    },

    onEditorChange () {
      if (this.error) {
        this.error = false
      }
    },

    beforeClose (event) {
      var code = this.code.trim()

      if (code.length === 0) {
        if (this.selectedId === this.rootId) {
          if (event) {
            event.stop()
          }
          this.error = 'Root node can\'t be empty.'
          return
        } else {
          var id = this.selectedId

          this.$store.commit('deleteStruct', id)
          console.log('Source editor: Removed node ' + id)
          return
        }
      }

      var xml = util.parser.string2Xml(code)
      var parsererror = xml.querySelector('parsererror')
      /**
       * If el contains <parsererror/> node, it means that xml text
       * was not valid and will notify user about that
       */
      if (parsererror) {
        var div = parsererror.querySelector('div')
        var message = div ? div.textContent : 'error'

        event.stop()
        this.error = 'Parsing ' + message.trim() + '.'
        return
      }

      var json = Tree.json(this.nodes)
      var path = Tree.ancestors(this.nodes, this.selectedId)
      var partial = util.parser.structXml2Json(xml)
      var parent = json

      if (path.length === 0) {
        var error = 'Error occured while trying to find selected node. ' +
            'Seems that selected not either is not a folder or does not exist.'

        this.$notify({
          title: 'System error',
          text: error,
          type: 'error',
          duration: 600000
        })

        return
      }

      if (path.length === 1) {
        json = partial
      } else {
        for (var i = path.length - 1; i >= 0; i--) {
          var pitem = path[i]

          for (var j = 0; j < parent.content.length; j++) {
            var node = parent.content[j]

            if (node.attr.id === pitem.attr.id) {
              if (i === 0) {
                parent.content.splice(j, 1, partial)
              } else {
                parent = node
              }
              break
            }
          }
        }
      }

      Tree.populate(json, (error, nodes) => {
        if (error) {
          console.warn(error)
        }

        this.$store.commit('setNodes', nodes)
      })
    }
  },
  computed: {
    ...mapGetters([
      'nodes',
      'rootId',
      'selectedId',
      'selected'
    ])
  }
}
</script>
