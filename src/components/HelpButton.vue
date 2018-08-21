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
  <button
    :class="classes"
    ref="button"
    @click.stop="click"
    @mouseenter="mouseenter"
    @mouseleave="mouseleave">
    <span>{{params.value}}</span>
    <i
      v-if="toShow"
      class="fa fa-fw fa-question"
      style="font-size: 9px;"/>
  </button>
</template>
<script>
  export default {
    name: 'HelpButton',
    props: {
      params: {
        type: Object,
        required: true
      },
      delay: {
        type: Number, default: 1400
      }
    },
    data () {
      return {
        over: false,
        timeout: null
      }
    },
    computed: {
      toShow () {
        return !!(this.params.help || this.params.$msg)
      },
      classes () {
        return ['help-button', this.params.$type || '']
      }
    },
    methods: {
      click (event) {
        this.$emit('click', event)
        this.hideTooltip(0)
      },
      mouseenter (event) {
        var key = this.params.$msg
        var message = key ? window.I18n.en[key] : ''
        var element = this.$refs.button
        var rect = element.getBoundingClientRect()

        if (this.toShow) {
          this.timeout = setTimeout(() => {
            const event = {key, rect, message, event, params: this.params}
            this.over = true
            this.$emit('hover', event)
          }, this.delay)
        }
      },
      hideTooltip (delay = 0) {
        if (this.timeout) {
          clearTimeout(this.timeout)
          this.timeout = null
        }

        if (this.over) {
          setTimeout(() => {
            this.over = false
            this.$emit('hout')
          }, delay)
        }
      },
      mouseleave () {
        this.hideTooltip(1000)
      }
    }
  }
</script>
