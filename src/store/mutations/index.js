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
 * Store contains global application state.
 *
 * All data that is shared between multiple components should be stored
 * in this state object.
 *
 * More about Vuex and the way it works: https://vuex.vuejs.org/en/
 */
import Vue from 'vue'
import errors from './errors'
import structs from './structs'

const mutations = {
  setUserId (state, userId) {
    state.userId = userId || null
  },
  setNodes (state, nodes) {
    state.selectedId = null
    state.nodes = nodes

    for (var i in nodes) {
      if (nodes[i].is_root) {
        state.rootId = i
        return
      }
    }

    state.rootId = null
  },

  setNodeOverId (state, id) {
    state.nodeOverId = id
  },

  setSource (state, object) {
    state.source = object
  },

  setFlags (state, flags) {
    for (var i in flags) {
      state.flags[i] = flags[i]
    }
  }
}

Vue.util.extend(mutations, structs)
Vue.util.extend(mutations, errors)

export default mutations
