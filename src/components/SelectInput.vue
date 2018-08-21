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
  <div class="select-input">
    <input
      type="text"
      :value="val"
      :placeholder="placeholder"
      @focus="focus"
      @blur="blur"
      @input="input">
    <ul
      v-if="visible && filtered.length > 0"
      class="select-input-dropdown">
      <li
        v-for="item in filtered"
        :key="item"
        @mousedown.stop="select(item, $event)">
        {{item}}
      </li>
    </ul>
    </div>
  </div>
</template>
<script>
export default {
  name: 'DropdownInput',
  props: {
    value: {
      type: String,
      default: ''
    },
    filter: {
      type: Function,
      default: null
    },
    size: {
      type: Number,
      default: 4
    },
    list: {
      type: Array,
      default () {
        return []
      }
    },
    placeholder: {
      type: String,
      default: ''
    }
  },
  watch: {
    value: function(nvalue) {
      this.val = nvalue
    }
  },
  data () {
    return {
      visible: false,
      val: this.value
    }
  },
  computed: {
    filterFunction () {
      if (this.val.length === 0) {
        return v => v
      }

      return typeof this.filter === 'function'
          ? this.filter
          : v => v.indexOf(this.val) === 0
    },
    filtered () {
      return this.list.filter(this.filterFunction)
    }
  },
  methods: {
    emitSrcEvent (name, srcEvent) {
      this.$emit(name, {value: this.val, srcEvent})
    },
    select (value, event) {
      this.val = value
      this.emitSrcEvent('input', event)
    },
    focus (event) {
      this.visible = true
      this.emitSrcEvent('focus', event)
    },
    blur (event) {
      this.visible = false
      this.emitSrcEvent('blur', event)
    },
    input (event) {
      this.val = event.target.value
      this.emitSrcEvent('input', event)
    }
  }
}
</script>
<style lang="scss">
.select-input {
  position: relative;
  box-sizing: border-box;

  input {
    position: relative;
    box-sizing: border-box;
    width: 100%;
    margin: 0;
  }

  .select-input-dropdown {
    display: block;
    position: absolute;
    box-sizing: border-box;
    border: 1px solid #eee;

    width: 100%;
    left: 0;
    z-index: 1000;
    list-style: none;
    padding: 0;
    margin: 0;
    cursor: pointer;
    background: #fdfdfd;

    li {
      margin: 0;
      padding: 4px;

      &:hover {
        background: #f8f8f8;
      }
    }
  }
}
</style>
