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
    :name="name"
    :height="500"
    @before-open="beforeOpen">
    <tab-header
      :list="tabs"
      :default="tab"
      @select="selectTab"/>
    <div style="height: 500px;">
      <slot
        v-if="tab === 'browser storage'"
        name="browser storage"/>
      <slot
        v-if="tab === 'sparkl'"
        name="sparkl"/>
      <slot
        v-if="tab === 'file system'"
        name="file system"/>
    </div>
  </modal>
</template>
<script>
import TabHeader from '../TabHeader'

var tabs = [
  'file system',
  'browser storage',
  'sparkl'
]

export default {
  name: 'ModalWrapper',
  props: ['name'],
  components: {
    TabHeader
  },
  data () {
    return {
      tabs,
      tab: tabs[0]
    }
  },
  methods: {
    selectTab (name) {
      this.tab = name
      this.$emit('tabChange', this.tab)
    },
    beforeOpen () {
      this.$emit('before-open')
    }
  }
}
</script>
