<?xml version="1.0" encoding="UTF-8"?>
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

  Generates errors, warnings and hints for svc_subr elements.

  This should be included in validate_core.xsl thus:

    <xsl:include href="(path)validate_svc_phidget.xsl"/>

  List of help topic IDs
    api_phidget_spec
      api_phidget_spec_kind
      api_phidget_spec_domains
    api_phidget_params
      api_phidget_params_interfacekit
      api_phidget_params_advancedservo
      api_phidget_params_rfid

-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    Extension passes invoked from validate_core.xsl
  -->
  <xsl:template name="validate_svc_phidget">
    <xsl:apply-templates select=".|@*" mode="svc_phidget_pass_0"/>
    <xsl:apply-templates select=".|@*" mode="svc_phidget_pass_1"/>
    <xsl:apply-templates select=".|@*" mode="svc_phidget_pass_2"/>
  </xsl:template>

  <!--
    PASS 0
  -->

  <!--
    Prompt for phidget.spec and phidget.params props.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="*[@provision='phidget']">

    <xsl:if test="not(prop[@name='phidget.spec'])">
      <error message="missing_prop"
        value="phidget.spec"
        help="api_phidget_spec">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_phidget_1">
          Specifies phidget kind and domains.
        </msg>
      </error>
    </xsl:if>

    <xsl:if test="not(prop[@name='phidget.params'])">
      <warning message="missing_prop"
        value="phidget.params"
        help="api_phidget_params">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_phidget_2">
          Matches up phidget sensors and i/o with SPARKL fields.
        </msg>
      </warning>
    </xsl:if>
  </xsl:template>

  <!--
    Mandate kind= attribute on phidget.spec.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="prop[@name='phidget.spec'][not(@kind)]">
    <error message="missing_attribute"
      value="kind"
      help="api_phidget_spec_kind">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_4">
        Specifies the phidget kind.
      </msg>
    </error>
  </xsl:template>

  <!--
    Hint domains= attribute on phidget.spec.
  -->
  <xsl:template mode="svc_phidget_pass_1"
    match="prop[@name='phidget.spec'][not(@domains)]">
    <hint message="missing_attribute"
      value="domains"
      help="api_phidget_spec_domains">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_3">
        Service selects phidget(s) on these domain(s).
      </msg>
    </hint>
  </xsl:template>

  <!--
    Hint refresh= attribute on phidget.spec.
  -->
  <xsl:template mode="svc_phidget_pass_2"
    match="prop[@name='phidget.spec'][not(@refresh)]">
    <hint message="missing_attribute"
      value="refresh">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_3a">
        Attachment refresh period, e.g. 5s, 1m etc
      </msg>
    </hint>
  </xsl:template>

  <!--
    Prompt for phidget kind= attribute value.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="prop[@name='phidget.spec']/@kind">

    <hint message="attribute_value"
      value="kind">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="PhidgetInterfaceKit"/>
        <option value="PhidgetAdvancedServo"/>
        <option value="PhidgetRFID"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    Prompt for phidget.params attributes for PhidgetInterfaceKit.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="*[prop[@kind='PhidgetInterfaceKit']]/prop[@name='phidget.params']">

    <hint message="missing_attribute"
      value="input0-7"
      help="api_phidget_params_interfacekit">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_5">
        Digital input 0..7, input is true/false
      </msg>
    </hint>

    <hint message="missing_attribute"
      value="output0-7"
      help="api_phidget_params_interfacekit">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_6">
        Digital output 0..7, output is true/false
      </msg>
    </hint>

    <hint message="missing_attribute"
      value="sensor0-7"
      help="api_phidget_params_interfacekit">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_7">
        Analogue sensor 0..7, output is 0-999
      </msg>
    </hint>
  </xsl:template>

  <!--
    Prompt for phidget.params attributes for PhidgetAdvancedServo.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="*[prop[@kind='PhidgetAdvancedServo']]/prop[@name='phidget.params']">

    <hint message="missing_attribute"
      value="position0-7"
      help="api_phidget_params_advancedservo">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_8">
        Servo motor number 0..7, position is 0-999
      </msg>
    </hint>
  </xsl:template>

  <!--
    Hint for phidget.param attribute field mappings.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="prop[@name='phidget.params']/@*">

    <xsl:choose>
      <xsl:when test="starts-with(local-name(),'position')">
        <xsl:call-template name="hint-fields-in-scope">
          <xsl:with-param name="type" select="'integer'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="starts-with(local-name(),'sensor')">
        <xsl:call-template name="hint-fields-in-scope">
          <xsl:with-param name="type" select="'integer'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="starts-with(local-name(),'input')">
        <xsl:call-template name="hint-fields-in-scope">
          <xsl:with-param name="type" select="'boolean'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="starts-with(local-name(),'output')">
        <xsl:call-template name="hint-fields-in-scope">
          <xsl:with-param name="type" select="'boolean'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="local-name()='rfid'">
        <xsl:call-template name="hint-fields-in-scope">
          <xsl:with-param name="type" select="'string'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="local-name()='led'">
        <xsl:call-template name="hint-fields-in-scope">
          <xsl:with-param name="type" select="'boolean'"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    Prompt for phidget.params attributes for PhidgetRFID.
  -->
  <xsl:template mode="svc_phidget_pass_0"
    match="*[prop[@kind='PhidgetRFID']]/prop[@name='phidget.params']">

    <hint message="missing_attribute"
      value="output0-1"
      help="api_phidget_params_rfid">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_10">
        Digital output 0..1, output is true/false
      </msg>
    </hint>

    <hint message="missing_attribute"
      value="led"
      help="api_phidget_params_rfid">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_11">
        Onboard LED output is true/false
      </msg>
    </hint>

    <hint message="missing_attribute"
      value="antenna"
      help="api_phidget_params_rfid">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_12">
        Enable RFID antenna is true/false
      </msg>
    </hint>

    <hint message="missing_attribute"
      value="rfid"
      help="api_phidget_params_rfid">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_phidget_13">
        RFID output is a string value
      </msg>
    </hint>
  </xsl:template>

  <!--
    The default rule in each mode generates no error or warning,
    and has lowest priority.
  -->
  <xsl:template match="node()|@*" mode="svc_phidget_pass_0" priority="-1"/>
  <xsl:template match="node()|@*" mode="svc_phidget_pass_1" priority="-1"/>
  <xsl:template match="node()|@*" mode="svc_phidget_pass_2" priority="-1"/>

</xsl:stylesheet>
