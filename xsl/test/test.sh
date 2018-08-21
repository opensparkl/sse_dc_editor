#!/bin/sh
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
# Runs one or more tests.
# Usage:
#   ./test.sh [-debug] [test_dir] [test_name]
#
# If test_dir is specified, all tests in that dir are run.
# If both test_dir and test_name are specified, only that test is run.
# If neither test_dir nor test_name are specified, all tests are run.
#
# Test dirs can have any name, and each test looks like this:
# 1. Input document in TEST_NAME.in.xml
# 2. Expected output in TEST_NAME.expected.xml
#
# The output of the validation transform is placed in TEST_NAME.out.xml.
# This is diff-ed against TEST_NAME.expected.xml, and the diff output
# indicates with < lines where output is missing, and with > lines where
# unexpected output has been generated.
#

if [ "$1" = "-debug" ]
then
  DEBUG=true
  shift
else
  DEBUG=false
fi

TEST_DIRS=${1-`ls -d */ | cut -f1 -d'/'`}
echo = Test directories: ${TEST_DIRS}

for TEST_DIR in ${TEST_DIRS}
do
  echo
  echo == Entering ${TEST_DIR}
  TEST_NAMES=${2-`find ${TEST_DIR}/*.in.xml | cut -f2 -d'/' | cut -f1 -d'.'`}
  echo == Test names: ${TEST_NAMES}

  for TEST_NAME in ${TEST_NAMES}
  do
    if [ -f ${TEST_DIR}/${TEST_NAME}.args ]
    then
      TEST_ARGS=$(cat ${TEST_DIR}/${TEST_NAME}.args)
      echo === Running ${TEST_DIR}/${TEST_NAME} with args: ${TEST_ARGS}
    else
      TEST_ARGS=""
      echo === Running ${TEST_DIR}/${TEST_NAME}
    fi
    TEST_IN=${TEST_DIR}/${TEST_NAME}.in.xml
    TEST_OUT=${TEST_DIR}/${TEST_NAME}.out.xml
    TEST_EXPECTED=${TEST_DIR}/${TEST_NAME}.expected.xml
    TEST_CMD="xsltproc ${TEST_ARGS} -o ${TEST_OUT} test_main.xsl ${TEST_IN}"

    if [ "${DEBUG}" = "true" ]
    then
      echo ==== TEST_CMD: ${TEST_CMD}
      echo ==== TEST_IN: ${TEST_IN}
      cat ${TEST_IN}
      echo
    fi

    $TEST_CMD

    if [ "${DEBUG}" = "true" ]
    then
      echo ==== TEST_OUT: ${TEST_OUT}
      cat ${TEST_OUT}
      echo
    fi

    diff ${TEST_EXPECTED} ${TEST_OUT}

  done

done
