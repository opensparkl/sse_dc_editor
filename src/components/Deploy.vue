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
    name="deploy"
    classes="vue-modal deploy-modal">
    <tree @select="select"/>
    <div class="s-button-holder">
      <button
        class="button"
        @click="deploy">save</button>
    </div>
  </modal>
</template>
<script>
import { mapGetters } from 'vuex'
import tree from '../util/tree'
import api from '../api'
import Tree from './Tree'
import helpers from '../mixins/helpers'

export default {
  name: 'DeployDialog',
  components: {Tree},
  mixins: [helpers],
  data () {
    return {
      path: ''
    }
  },
  methods: {
    select (event) {
      this.path = event.state.path
    },
    deploy () {
      this.validate((errors, counts) => {
        var xml = tree.xml(this.nodes, null, {
          ignoreAttr: 'id'
        })

        api.source.update(this.path, xml)
          .then(response => {
            this.$notify({
              text: 'Successfully saved document'
            })

            this.$store.commit('setSource', {
              folder: this.path,
              host: ''
            })
            this.$store.dispatch('save')
            this.$modal.hide('deploy')
          })
          .catch((error) => {
            this.$notify({
              type: 'error',
              duration: 600000,
              text: error
            })
          })
      })
    }
  },
  computed: {
    ...mapGetters([
      'nodes',
      'selectedId',
      'selected'
    ])
  }
}
</script>
<style lang="scss">
  .deploy-modal {
    box-sizing: border-box;
    overflow: auto;
    height: 400px;
    padding: 10px 10px 10px 5px;
  }
</style>
