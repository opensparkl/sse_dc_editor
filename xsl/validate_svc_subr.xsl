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

    <xsl:include href="(path)validate_svc_subr.xsl"/>

  List of help topic IDs
    api_subr_export
      api_subr_export_key
    api_subr_import
      api_subr_import_key
      api_subr_import_user
    api_subr_spec
      api_subr_spec_function
      api_subr_spec_parameter
      api_subr_spec_ancestor
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    Extension passes invoked from validate_core.xsl
  -->
  <xsl:template name="validate_svc_subr">
    <xsl:apply-templates select=".|@*" mode="svc_subr_pass_0"/>
    <xsl:apply-templates select=".|@*" mode="svc_subr_pass_1"/>
  </xsl:template>

  <!--
    PASS 0
  -->

  <!--
    Validate subr service, hinting subr.import and subr.export props.
  -->
  <xsl:template mode="svc_subr_pass_0"
    match="*[@provision='subr']">
    <xsl:if test="not(prop[@name='subr.import'])">
      <hint message="missing_prop"
        value="subr.import"
        help="api_subr_import">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_1">
          Use subr.import to import a service from elsewhere in the
          configuration tree. Request and consume operations can then
          be mapped to solicit and notify operations on the imported
          service.
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(prop[@name='subr.export'])">
      <hint message="missing_prop"
        value="subr.export"
        help="api_subr_export">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_2">
          Use subr.export to export this service such that the
          solicit and notify operations on this service can be
          mapped to request and consume operations on other
          services.
        </msg>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    Validate the subr.import prop, requiring key= and hinting user=
    attributes.
  -->
  <xsl:template mode="svc_subr_pass_0"
    match="prop[@name='subr.import']">
    <xsl:if test="not(@key)">
      <error message="missing_attribute"
        value="key"
        help="api_subr_import_key">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_3">
          Imports the service which specifies this key in its subr.export
          property.
        </msg>
      </error>
    </xsl:if>

    <xsl:if test="not(@user)">
      <hint message="missing_attribute"
        value="user"
        help="api_subr_import_user">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_4">
          Use this if the service to import is in a different user's
          configuration tree.
        </msg>
      </hint>
    </xsl:if>
  </xsl:template>

   <!--
    Validate the subr.export prop, requiring the key= attributes.
  -->
  <xsl:template mode="svc_subr_pass_0"
    match="prop[@name='subr.export']">
    <xsl:if test="not(@key)">
      <error message="missing_attribute"
        value="key"
        help="api_subr_export_key">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_5">
          To import this service, a foreign service specifies the key value.
        </msg>
      </error>
    </xsl:if>
  </xsl:template>

  <!--
    Request and consume can specify subr.spec prop with
    function= , ancestor= and ParamN=fieldX
  -->
  <xsl:template mode="svc_subr_pass_0"
    match="*[@service]">

    <xsl:variable name="service" select="@service"/>

    <xsl:if test="ancestor::*/*[@name=$service][1][@provision='subr']">
      <xsl:if test="not(prop[@name='subr.spec'])">
        <hint message="missing_prop"
          value="subr.spec"
          help="api_subr_spec">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_subr_7">
            Use subr.spec to specify the function name to be invoked if
            different from the operation name.
          </msg>
        </hint>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--
    Notify and solicit subr.spec can have function= and ParamN=fieldX
    attributes.
  -->
  <xsl:template mode="svc_subr_pass_0"
    match="prop[@name='subr.spec']">

    <xsl:if test="not(@function)">
      <hint message="missing_attribute"
        value="function"
        help="api_subr_spec_function">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_8">
          Optional function name (default is the operation name)
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="(parent::consume|parent::request) and not(@ancestor)">
      <hint message="missing_attribute"
        value="ancestor"
        help="api_subr_spec_ancestor">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_subr_10">
          Optionally specify an ancestor folder name of the called subroutine.
        </msg>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    Override notify or solicit subr.spec content-type= predicate content.
  -->
  <xsl:template mode="svc_subr_pass_0"
    match="prop[@name='subr.spec'][parent::notify or parent::solicit]/@content-type">
    <hint message="attribute_value"
      value="content-type">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="text/x-erlang"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    Solicit and notify ops can specify subr.spec prop.
  -->
  <xsl:template mode="svc_subr_pass_1"
    match="*[@clients]">
    <xsl:variable name="clients" select="@clients"/>
    <xsl:if test="ancestor::*/*[contains($clients,@name)][@provision='subr']">
      <xsl:if test="not(prop[@name='subr.spec'])">
        <hint message="missing_prop"
          value="subr.spec"
          help="api_subr_spec">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_subr_6">
            Use subr.spec to specify the function name, if different from
            the operation name, to enable callers to invoke this subroutine.
          </msg>
        </hint>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--
    The default rule in each mode generates no error or warning,
    and has lowest priority.
  -->
  <xsl:template match="node()|@*" mode="svc_subr_pass_0" priority="-1"/>
  <xsl:template match="node()|@*" mode="svc_subr_pass_1" priority="-1"/>

</xsl:stylesheet>
