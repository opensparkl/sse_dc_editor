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
 * Prints Sparkl copyrights in inspector.
 */
export default () => {
  // var copyright = 'SPARKL Editor / by Yev. Vlasenko / @sparkl'
  var copyright = 'SPARKL Editor (c) All rights reserved'
  var style = `
    background:#369BE9;
    color:#fff;
    padding:5px 10px;
    border-radius:3px;
  `

  try {
    console.log('\n%c' + copyright, style)
    console.log('\n')
  } catch (e) {
    console.log(copyright)
  }
}
