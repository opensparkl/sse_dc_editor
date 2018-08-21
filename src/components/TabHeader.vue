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
  <div
    class="tab-list-component"
    :style="wrapperStyle">
    <ul class="tab-list">
      <li
        v-for="item in list"
        :class="{ active: item === active }"
        :style="itemStyle">
        <button @click.stop="select($event, item)">{{item}}</button>
      </li>
    </ul>
  </div>
</template>
<script>
  export default {
    name: 'TabHeader',
    props: {
      list: {
        required: true,
        type: Array
      },
      default: {
        type: String
      },
      width: {
        type: String,
        default: '100%'
      }
    },
    data () {
      return {
        active: this.default || this.list[0] || null
      }
    },
    computed: {
      wrapperStyle () {
        return {
          width: this.width
        }
      },
      itemStyle () {
        return {
          width: (100 / this.list.length).toFixed(1) + '%'
        }
      }
    },
    methods: {
      select (event, name) {
        this.active = name
        this.$emit('select', name, event)
      }
    }
  }
</script>
