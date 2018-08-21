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
  name="import"
  @before-open="beforeOpen">
  <div slot="file system">
    <dropzone
      width="600px"
      height="456px"
      @cancel="close"
      @update="updateDrop"/>
  </div>
  <div slot="browser storage">
    <div style="padding: 10px;">
      <table
        v-if="names.length > 0"
        class="local-storage-table">
        <tr v-for="name in names">
          <td @click.stop="lsRestore(name)">
            <i class="fa fa-fw fa-folder-o"/> {{name}}
          </td>
          <td @click.stop="lsRemove(name)">
            <i class="fa fa-fw fa-remove"/>
          </td>
        </tr>
      </table>
      <div
        v-else
        style="line-height: 400px; text-align: center; color: #bfbfbf;">
        No records in browser storage
      </div>
    </div>
  </div>
  <div slot="sparkl">
    <sparkl-tree :source="defaultRootFolder"/>
    <div v-if="importer.path"
         class="s-button-holder">
      <button class="button"
              @click="openFromSparkl()">open</button>
    </div>
  </div>
</modal-wrapper>
</template>
<script>
import { mapGetters } from 'vuex'
import config from '../../config'
import TabHeader from '../TabHeader'
import Dropzone from '../Dropzone'

import ModalWrapper from './ModalWrapper'
import { importFromSparkl } from '../../helpers/importer'
import SparklTree from '../SparklRestoreItem'

var prefix = config.storage.lsPrefix

export default {
  name: 'Restore',
  components: {
    TabHeader,
    Dropzone,
    SparklTree,
    ModalWrapper
  },
  data () {
    return {
      names: [],
      defaultRootFolder: {
        tag:'folder',
        attr: {
          path:'',
          name: 'Home'
        }
      },
      sparkl: {
        breadcrumbs: [],
        map: [],
        dict: {}
      }
    }
  },
  methods: {
    updateDrop (nodes) {
      this.close()

      if (nodes) {
        this.$store.commit('setNodes', nodes)
      }
    },
    close () {
      this.$modal.hide('import')
    },
    beforeOpen () {
      this.names = this.getLsList()
    },
    openFromSparkl () {
      var source = {
        host: '',
        folder: this.importer.path
      }

      importFromSparkl(source, (error, nodes) => {
        if (error) {
          console.warn(error)
          this.$notify({
            type: 'error',
            title: 'Import error',
            text: JSON.stringify(error)
          })
          return
        }

        this.$store.commit('setSource', source)
        this.$store.commit('setNodes', nodes)
        this.importer.path = null
        this.close()
      })
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
    },
    lsRestore (name) {
      this.$store.dispatch('fetch', prefix + name)
      this.close()
    },
    lsRemove (name) {
      delete localStorage[prefix + name]
      this.names = this.getLsList()
    }
  },
  computed: {
    ...mapGetters([
      'nodes',
      'selectedId',
      'selected',
      'importer'
    ])
  }
}
</script>
<style lang="scss">
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
