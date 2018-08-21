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
<div :class="{ 'file-drop': true, 'is-advanced': isAvanced, 'is-over': isOver }"
     :style="{ width, height }">
  <div
    class="file-drop-area"
    @dragenter.stop="enter"
    @dragleave.stop="leave"
    @dragover.stop="over"
    @drop="drop">
    <div class="file-drop-icon">
      <i class="fa fa-inbox" aria-hidden="true"/>
    </div>
    <input
      type="file"
      style="display: none"
      ref="uploader"
      @change="change"/>
    <label for="file">
    <template v-if="!fileName">
      <span
        class="choose-button"
        @click.stop="selectFile">Choose a file</span>
      <span v-if="isAdvanced"> or drag it here</span>
    </template>
    <template v-else>
      <div style="padding-bottom: 5px;">{{fileName}}</div>
      <div class="button-holder">
        <button
          class="button"
          @click.stop="cancel">Cancel</button>
        <button
          class="button"
          @click.stop="open">Open</button>
      </div>
    </template>
  </label>
  </div>
</div>
</template>
<script>
import { importFromFile } from '../helpers/importer'

var isAdvancedUpload = (function () {
  var div = document.createElement('div')

  return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) &&
    'FormData' in window &&
    'FileReader' in window
})()

export default {
  name: 'FileDropZone',
  components: {},
  props: {
    width: {
      type: String,
      default: '100%'
    },
    height: {
      type: String,
      default: '100%'
    }
  },
  data () {
    return {
      isAdvanced: isAdvancedUpload,
      isOver: false,
      fileName: null,
      results: null,
      size: {}
    }
  },
  methods: {
    enter () {
      this.isOver = true
    },
    leave () {
      this.isOver = false
    },
    over (event) {
      event.preventDefault()
    },
    drop (event) {
      this.leave()
      this.readFile(event.dataTransfer.files[0])
      event.preventDefault()
    },
    selectFile () {
      this.$refs.uploader.click()
    },
    change (event) {
      this.readFile(event.target.files[0])
    },
    readFile (file) {
      importFromFile(file, (error, nodes) => {
        if (error) {
          this.fileName = null
          return this.$notify(error)
        }

        this.fileName = file.name
        this.results = nodes
      })
    },

    cancel () {
      this.fileName = null
      this.results = null
      this.$emit('cancel')
    },

    open () {
      this.$emit('update', this.results, this.fileName)
    }
  }
}
</script>
<style lang="scss">
$color: #369BE9;

.file-drop {
  display: block;
  box-sizing: border-box;
  text-align: center;
  padding: 4px;
  font-size: 14px;

  .file-drop-icon {
    pointer-events: none;
     font-size: 140px;
     text-align: center;
     color: $color;
     padding-top: 80px;
     padding-bottom: 130px;
  }

  .choose-button {
    font-weight: 600;
    text-decoration: underline;
    cursor: pointer;
  }

  .file-drop-area {
    position: relative;
    box-sizing: border-box;
    border-radius: 3px;
    width: 100%;
    height: 100%;
    background-color: white;
    transition: 0.3s all;
    transform-origin: center;

    .button-holder {
      position: absolute;
      padding-left: 6px;
      padding-right: 6px;
      bottom: 0;
    }

    button {
      text-align: center;
      width: 288px;
    }
  }

  &.is-over .file-drop-area {
    transform: scale(0.96);
    background-color: mix($color, white, 20%);
  }
}
</style>
