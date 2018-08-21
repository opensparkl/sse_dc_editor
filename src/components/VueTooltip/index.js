/**
 * Copyright 2018 SPARKL Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Tooltip plugin.
 */
var anchors = ['left', 'right', 'top', 'bottom']
var template = `
  <div class="global-box tooltip"
       :style="style"
       v-if="msg"
       v-html="msg"></div>
`

var px = (number = 0) => {
  return typeof number === 'number'
    ? (number + 'px')
    : number
}

export default {
  install (Vue) {
    if (this.installed) {
      return
    }

    this.installed = true

    var data = { msg: '', style: {} }

    var self = {
      show (message, params = {}) {
        data.msg = message || ''
        data.style = {}

        anchors.forEach(key => {
          if (params.hasOwnProperty(key)) {
            data.style[key] = px(params[key])
          }
        })
      },
      hide () {
        data.msg = ''
        data.style = {}
      }
    }

    Vue.prototype.$tooltip = self
    Vue.component('Tooltip', {
      template,
      data: () => data
    })
  }
}
