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
  <section class="editor">
    <validation-error/>
    <notifications
      :speed="300"
      :duration="3000"
      position="bottom right"/>
    <v-dialog/>
    <modal-props/>
    <modal-source/>
    <modal-import/>
    <modal-export/>
    <modal-deploy/>
    <div :class="{ content: true, minified }">
      <div class="content-item aside is-left">
        <subjects/>
      </div>
      <div class="content-item center">
        <div class="window">
          <container
            v-if="rootId"
            :id="rootId"
            :is-root="true"/>
        </div>
      </div>
      <div class="content-item aside is-right">
        <sidebar/>
      </div>
    </div>
    <tooltip/>
  </section>
</template>

<script>
import _ from 'lodash'
import Subjects from './Subjects'
import Container from './NodeContainer'
import Sidebar from './Sidebar'
import ModalProps from './Props'
import ModalSource from './Source'
import ModalDeploy from './Deploy'
import ModalImport from './ImportExport/Import'
import ModalExport from './ImportExport/Export'
import ValidationError from './ValidationError'
import TabHeader from './TabHeader'
import { mapGetters } from 'vuex'
import api from '../api'
import history from '../mixins/history'

import EditorTree from './EditorTree'

const NO_USER = 'G-0-0-0'

let app = {
  components: {
    Subjects,
    Sidebar,
    ModalProps,
    ModalSource,
    ModalDeploy,
    ModalImport,
    ModalExport,
    Container,
    TabHeader,
    EditorTree,
    ValidationError
  },
  mixins: [history],
  computed: {
    ...mapGetters([
      'nodes',
      'rootId',
      'flags',
      'source',
      'errors'
    ]),
    minified () {
      return this.flags.minified
    }
  },
  beforeCreate () {
    window.reset = () => {
      this.$store.dispatch('createEmpty')
      this.$store.dispatch('save')

      setTimeout(() => {
        window.location.reload()
      }, 500)
    }

    window.addEventListener('blur', () => {
      if (this.rootId) {
        let root = this.nodes[this.rootId]

        if (root) {
          document.title = root.attr.name
          return
        }
      }

      document.title = 'SPARKL Editor'
    })

    window.addEventListener('focus', () => {
      document.title = 'SPARKL Editor'
    })

    api.user.self()
      .then(response => response.data.attr)
      .then(user => {
        this.initHistory({
          prefix: user.name || NO_USER,
          debug: true
        })

        if (user.id === NO_USER) {
          this.$modal.show('dialog', {
            title: 'Authentication',
            text: 'You are not authenticated.',
            buttons: [
              { title: 'Ok' }
            ]
          })
        }

        var redirect = localStorage['sparkl:redirect']

        if (redirect) {
          var source = JSON.parse(redirect)
          delete localStorage['sparkl:redirect']

          this.openDocument(source)
        } else {
          window.backup.skipSave = true
          this.openLatestDocument()
        }

        document.onkeydown = (e) => {
          var bodyIsActive = document.activeElement.nodeName === 'BODY'
          var metaKey = e.metaKey || e.ctrlKey

          if (bodyIsActive && metaKey && e.keyCode === 90) {
            window.backup.skipSave = true
            this.revertDocument()
          }
        }
      })
      .catch(error => {
        console.log(error)
      })
  },
  watch: {
    nodes: {
      handler: function () {
        if (Object.keys(this.errors).length === 0) {
          this.$store.commit('deleteErrors')
        }

        if (window.backup.skipSave) {
          window.backup.skipSave = false
        } else {
          this.cache.apply(this)
        }
      },
      deep: true
    }
  },
  data () {
    return {
      loaded: false
    }
  },
  methods: {
    cache: _.debounce(function () {
      this.$store.dispatch('save')
    }, 500)
  }
}

export default app
</script>
