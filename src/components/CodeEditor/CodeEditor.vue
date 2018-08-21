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
  <div class="code-editor">
    <div class="code-editor-top-bar">
      <div class="code-editor-nav-wrapper">
        <div class="code-editor-nav">
          <i
            class="fa fa-fw fa-dedent"
            v-tooltip.bottom="'Dedent'"
            @click="dedent"/>
          <i
            class="fa fa-fw fa-indent"
            v-tooltip.bottom="'Indent'"
            @click="indent"/>
        </div>
      </div>

      <div class="code-editor-nav-wrapper">
        <div class="code-editor-nav">
          <i
            class="fa fa-fw fa-undo"
            v-tooltip.bottom="'Undo'"
            :class="{ disabled: historySize.undo === 0 }"
            @click="undo"/>
          <i
            class="fa fa-fw fa-repeat"
            v-tooltip.bottom="'Redo'"
            :class="{ disabled: historySize.redo === 0 }"
            @click="redo"/>
        </div>
      </div>

      <div class="code-editor-nav-wrapper">
        <div class="code-editor-nav">
          <i
            class="fa fa-fw fa-eraser"
            v-tooltip.bottom="'Remove trailing spaces'"
            @click="tabsToSpaces"/>
        </div>
      </div>
    </div>
    <div class="code-editor-content">
      <codemirror
        :options="mergedOptions"
        :debugger="false"
        v-model="localText"
        @ready="onEditorReady"
        @change="onEditorChange"/>
    </div>
  </div>
</template>

<script>
import defaultOptions from './defaultOptions'
import { codemirror, CodeMirror } from 'vue-codemirror'
import showInvisibles from './showInvisibles'

const ENDLINE = '\n'

showInvisibles(CodeMirror)

export default {
  name: 'CodeEditor',
  components: {
    codemirror
  },
  props: {
    options: {
      type: Object,
      default: () => {
        return {
          mode: 'text/plain'
        }
      }
    },
    value: {
      type: String,
      default: ''
    }
  },
  watch: {
    options: {
      handler: function (options) {
        this.$nextTick(() => {
          this.cm.refresh()
        })
      },
      immediate: true
    }
  },
  data () {
    return {
      localText: this.value,
      historySize: { undo: 0, redo: 0 },
      cm: null
    }
  },
  computed: {
    mergedOptions () {
      return {
        ...defaultOptions,
        ...this.options
      }
    }
  },
  methods: {
    undo () {
      this.cm.undo()
    },

    redo () {
      this.cm.redo()
    },

    indent (event) {
      if (this.cm.somethingSelected()) {
        this.cm.execCommand('indentMore')
      } else {
        this.indentAllText()
      }
    },

    dedent () {
      if (this.cm.somethingSelected()) {
        this.cm.execCommand('indentLess')
      } else {
        this.dedentAllText()
      }
    },

    indentAllText () {
      let indentUnit = this.cm.getOption('indentUnit')
      let whitespaces = Array(indentUnit + 1).join(' ')

      this.localText = this.cm.getValue()
        .split(ENDLINE)
        .map(v => whitespaces + v)
        .join(ENDLINE)
    },

    dedentAllText () {
      let indentUnit = this.cm.getOption('indentUnit')
      let whitespaces = Array(indentUnit + 1).join(' ')

      let map = (v) => {
        if (v.indexOf(whitespaces) === 0) {
          return v.substr(whitespaces.length)
        }

        return v
      }

      this.localText = this.cm.getValue()
        .split(ENDLINE)
        .map(map)
        .join(ENDLINE)
    },

    tabsToSpaces () {
      let indentUnit = this.cm.getOption('indentUnit')
      let whitespaces = Array(indentUnit + 1).join(' ')
      let text = this.cm.getValue()

      this.localText = text
        .replace(/\t/g, whitespaces)
        .replace(/\s+$/, '')
        .replace(/[ ]+\n/g, '\n')
    },

    onEditorReady (cm) {
      this.cm = cm
      this.cm.clearHistory()
      this.$emit('ready', cm)
    },

    onEditorChange (event) {
      this.localText = event
      this.$emit('input', this.localText)
      this.$emit('change', this.localText)

      this.historySize = this.cm.historySize()
    }
  }
}
</script>

<style lang="scss">
.code-editor {
  display: block;
  position: relative;
  width: 100%;
  height: 100%;
}

.code-editor-top-bar {
  position: absolute;
  box-sizing: border-box;
  width: 100%;
  padding: 5px 10px;
  top: 0;
  left: 0;

  z-index: 2;
}

.code-editor-nav-wrapper {
  display: inline-block;
}

.code-editor-content {
  padding-top: 52px;
  height: calc(100% - 52px);
  overflow: hidden;

  .CodeMirror {
    height: calc(100%);
  }
}

.code-editor-nav {
  display: flex;
  $lineHeight: 32px;

  margin: 5px;
  height: $lineHeight;

  box-shadow: 0 0 4px 0 rgba(232, 237, 250, 0.9),
    0 2px 4px 0 rgba(232, 237, 250, 0.6);
  border-radius: 5px;

  & > i {
    display: block;
    border-radius: 4px;

    height: $lineHeight;
    line-height: $lineHeight;

    width: 42px;
    color: rgb(102, 102, 102);
    cursor: pointer;

    &.disabled {
      opacity: 0.5;
    //  pointer-events: none;

      &:hover {
        background: inherit;
      }
    }

    &:hover {
      background: #f9f9f9;
    }
  }
}

.cm-tab {
  position: relative;

  &:before {
    display: relative;
    content: '»';
    color: #c8d2d7;
  }
}

.tooltip {
  display: block !important;
  z-index: 10000;

  .tooltip-inner {
    background: #657276;
    color: white;
    border-radius: 4px;
    padding: 5px 10px 4px;
  }

  .tooltip-arrow {
    width: 0;
    height: 0;
    border-style: solid;
    position: absolute;
    margin: 5px;
    border-color: #657276;
  }

  &[x-placement^="top"] {
    margin-bottom: 5px;

    .tooltip-arrow {
      border-width: 5px 5px 0 5px;
      border-left-color: transparent !important;
      border-right-color: transparent !important;
      border-bottom-color: transparent !important;
      bottom: -5px;
      left: calc(50% - 5px);
      margin-top: 0;
      margin-bottom: 0;
    }
  }

  &[x-placement^="bottom"] {
    margin-top: 5px;

    .tooltip-arrow {
      border-width: 0 5px 5px 5px;
      border-left-color: transparent !important;
      border-right-color: transparent !important;
      border-top-color: transparent !important;
      top: -5px;
      left: calc(50% - 5px);
      margin-top: 0;
      margin-bottom: 0;
    }
  }

  &[x-placement^="right"] {
    margin-left: 5px;

    .tooltip-arrow {
      border-width: 5px 5px 5px 0;
      border-left-color: transparent !important;
      border-top-color: transparent !important;
      border-bottom-color: transparent !important;
      left: -5px;
      top: calc(50% - 5px);
      margin-left: 0;
      margin-right: 0;
    }
  }

  &[x-placement^="left"] {
    margin-right: 5px;

    .tooltip-arrow {
      border-width: 5px 0 5px 5px;
      border-top-color: transparent !important;
      border-right-color: transparent !important;
      border-bottom-color: transparent !important;
      right: -5px;
      top: calc(50% - 5px);
      margin-left: 0;
      margin-right: 0;
    }
  }

  &[aria-hidden='true'] {
    visibility: hidden;
    opacity: 0;
    transition: opacity .15s, visibility .15s;
  }

  &[aria-hidden='false'] {
    visibility: visible;
    opacity: 1;
    transition: opacity .15s;
  }
}
</style>
