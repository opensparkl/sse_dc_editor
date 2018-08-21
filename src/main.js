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
 * Application entery point
 */
import Vue from 'vue'
import CodeMirror from 'vue-codemirror'
import store from './store'
import App from './components/App'
import Draggable from './plugins/draggable'
import VueModal from 'vue-js-modal'
import VueNotify from 'vue-notification'
import VueTooltip from './components/VueTooltip'
import VTooltip from 'v-tooltip'
import Icon from './components/Icon'
import config from './config'
import xslt from './util/xslt'
import copyright from './util/copyright'
import velocity from 'velocity-animate'

import '!style!css!sass!font-awesome/scss/font-awesome.scss'
import '!style!css!sass!./styles/style.scss'

Vue.use(VTooltip)
Vue.use(CodeMirror)
Vue.use(VueNotify, { velocity })
Vue.use(Draggable)
Vue.use(VueModal, { dialog: true })
Vue.use(VueTooltip)
Vue.component('Icon', Icon)

Draggable.config.debug = config.debug
xslt.use(config.xsl)

window.application = new Vue({
  store,
  el: '#app',
  render: r => r(App)
})

copyright()
