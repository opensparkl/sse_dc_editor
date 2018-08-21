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
  <div class="subject-list">
    <subject
      v-for="(icon, name) in components"
      :name="name"
      :icon="icon"
      :minified="minified"></subject>
   <div style="padding: 5px;">
     <a
      class="button full-width"
      target="docs"
      style="padding: 10px;"
      href="http://docs.sparkl.com?contextId=api_mix_comp">
      <icon v-if="minified" name="fa-question-circle"/>
      <span v-else>learn more...</span>
     </a>
   </div>
    <button class="minify-button" @click="minify">
        <i :class="['fa fa-fw', icon]"/>
    </button>
  </div>
</template>

<script>
import Subject from './Subject'
import config from '../config'
import {mapGetters} from 'vuex'

const API_DOCS_KEY = 'api_mix_comp'

export default{
  components: { Subject },
  data () {
    return {
      components: config.components,
      mixDocsUrl: config.docsUrl + API_DOCS_KEY
    }
  },
  computed: {
    ...mapGetters([
      'flags'
    ]),
    minified () {
      return this.flags.minified || false
    },
    icon () {
      return this.minified
          ? 'fa-angle-double-right'
          : 'fa-angle-double-left'
    }
  },
  methods: {
    minify () {
      this.$store.commit('setFlags', {minified: !this.minified})
    }
  }
}
</script>
<style lang="scss">
  .minify-button {
    display: block;
    position: absolute;
    opacity: 0.4;
    width: 100%;
    border: 0;
    margin: 0;
    padding: 0;
    left: 0;
    bottom: 0;
    height: 40px;
    line-height: 40px;
    background: white;

    &:hover {
      opacity: 0.6;
    }
  }
</style>
