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
 */
import Type from '../util/type'

export default {
  userId: state => state.userId,
  nodes: state => state.nodes,
  rootId: state => state.rootId,
  errors: state => state.errors,
  flags: state => state.flags,
  source: state => state.source,
  selectedId: state => state.selectedId,
  nodeOverId: state => state.nodeOverId,
  syncronized: state => state.syncronized,
  root (state) {
    return state.nodes[state.rootId] || null
  },
  importer: state => state.importer,
  selected (state) {
    if (state.selectedId) {
      return state.nodes[state.selectedId]
    }
    return null
  },
  selectedType (state, getters) {
    return Type.is(getters.selected)
  },
  selectedIsContainer (state, getters) {
    return Type.is(getters.selected) === 'container'
  }
}
