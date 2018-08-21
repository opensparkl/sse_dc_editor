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
<modal-wrapper
  name="export"
  @before-open="beforeOpen">
  <div
    slot="file system"
    style="padding: 10px;">
    <div class="very-large-icon">
      <i class="fa fa-fw fa-desktop"/>
    </div>
    <button
      class="button full-width with-icon"
      style="text-align: center"
      @click="saveFileSystem">Save to file system</button>
  </div>
  <div
    slot="browser storage"
    style="padding: 10px;">
    <div class="very-large-icon">
      <i class="fa fa-chrome" aria-hidden="true"/>
    </div>
    <button
      class="button full-width with-icon"
      style="text-align: center"
      @click="saveLocalStorage">Save to browser storage</button>
  </div>
  <div slot="sparkl">
    <sparkl-tree :source="{ tag: 'folder', attr: { path:'', name: 'Home' } }"/>
    <div
      v-if="importer.path"
      class="s-button-holder">
      <button
        class="button"
        @click="saveSparkl">save</button>
    </div>
  </div>
</modal-wrapper>
</template>
<script>
import { mapGetters } from 'vuex'
import config from '@/config'
import util from '@/util'
import tree from '@/util/tree'
import helpers from '@/mixins/helpers'
import api from '@/api'
import TabHeader from '../TabHeader'
import ModalWrapper from './ModalWrapper'
import SparklTree from '../SparklRestoreItem'

var prefix = config.storage.lsPrefix

export default {
  name: 'Restore',
  components: {TabHeader, SparklTree, ModalWrapper},
  mixins: [helpers],
  data () {
    return {
      names: [],
      sparkl: {
        breadcrumbs: [],
        map: [],
        dict: {}
      }
    }
  },
  methods: {
    saveFileSystem () {
      var filename = this.root.attr.name
      var text = tree.xmlString(this.nodes, null, {
        ignoreAttr: ['id']
      })

      util.download(text, filename, 'xml')
    },

    saveLocalStorage () {
      var name = this.root.attr.name
      var key = 'sparkl:store:' + name
      var tag = this.root.tag

      this.$store.dispatch('save', key)
      this.$notify({
        title: 'Successfully saved.',
        text: `Saved "${name}" ${tag} to the browser storage.`,
        type: 'success'
      })
    },

    saveSparkl () {
      this.validate((errors, counts) => {
        var xml = tree.xml(this.nodes, null, {
          ignoreAttr: 'id'
        })

        var name = xml.getAttribute('name')

        api.source.update(this.importer.path, xml)
          .then(response => {
            this.$notify({
              text: 'Successfully saved document'
            })

            this.$store.commit('setSource', {
              folder: this.path,
              host: ''
            })
            this.$store.dispatch('save')
            this.$modal.hide('export')
          })
          .catch(error => {
            var data = error.response.data
            var text = ''

            if (data.attr && data.attr.reason === 'duplicate') {
              text = `Failed to deploy ${name} because it already exists.`
            } else {
              text = `Failed to deploy ${name}...`
            }

            this.$notify({
              type: 'error',
              duration: 600000,
              text
            })
          })
      })
    },

    beforeOpen () {
      this.names = this.getLsList()
    },

    getLsList () {
      var names = []
      var plength = prefix.length

      for (var i = 0; i < localStorage.length; ++i) {
        var prefixed = localStorage.key(i)

        if (prefixed.indexOf(prefix) === 0) {
          names.push(prefixed.substr(plength))
        }
      }

      return names
    }
  },
  computed: {
    ...mapGetters([
      'root',
      'nodes',
      'selectedId',
      'selected',
      'importer'
    ])
  }
}
</script>
<style lang="scss">
  .very-large-icon {
    color: #369BE9;
    text-align: center;
    font-size: 128px;
    padding-top: 100px;
    padding-bottom: 150px;
  }

  .s-button-holder {
    position:absolute;
    width: 100%;
    bottom: 0;
    left: 0;
    padding-left: 6px;
    padding-right: 6px;

    .button {
      text-align: center;
      width: calc(100% - 12px);
    }
  }

  .local-storage-table {
    border: 0;
    box-sizing: border-box;
    border-collapse: collapse;

    tr {
      &:hover {
        background: #f8f8f8;
      }

      td:first-of-type {
        padding-left: 5px;
      }

      td:last-of-type {
        padding: 5px;
        width: 1%;
        font-size: 9px;
        opacity: 0.3;

        &:hover {
          opacity: 1;
        }
      }

      td {
        padding-top: 5px;
        padding-bottom: 5px;
        cursor: pointer;
      }
    }
  }
</style>
