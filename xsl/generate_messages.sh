#!/bin/bash
# Copyright 2018 SPARKL Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Usage:
#   ./generate_messages.sh
# Creates a js directory and places one .js file per validate_XXX.xsl
# file. This contains the messages for that validation transform which
# are used by the SDC ui.

COPYRIGHT="// Copyright (c) 2016 SPARKL Limited. All Rights Reserved."

pushd `dirname $0` > /dev/null
DIR=`pwd`
popd > /dev/null

TARGET=${DIR}/dist

if [ "$1" != "" ]; then
  TARGET=$1
fi

mkdir -p ${TARGET}

echo -n "${COPYRIGHT}" > ${TARGET}/validation_messages.js
echo Generating i18n en messages to validation_messages.js
echo Target: ${TARGET}

for file in ${DIR}/validate_*.xsl
do
  prefix=`basename ${file} | sed 's/\.xsl//'`
  jsfile=${TARGET}/${prefix}.js

  echo Generating i18n ${prefix}
  xsltproc ${DIR}/generate_messages.xsl ${file} >> ${TARGET}/validation_messages.js
done

echo Generating minified browser_main.xsl.
xsltproc -o ${TARGET}/browser_main.xsl ${DIR}/minify.xsl ${DIR}/main.xsl
