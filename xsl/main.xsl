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
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="validate_util.xsl"/>

  <!--
    List all XSL files to be included in the validation
    process here.

    This file can be specified directly in xsltproc for tests
    and development.

    The browser_main.xsl should be used in browser-side $.ajax,
    so that this file inherits the base URI set by that file's
    xsl:include element.
  -->
  <xsl:include href="validate_core.xsl"/>
  <xsl:include href="validate_instance_spec.xsl"/>
  <xsl:include href="validate_topology.xsl"/>
  <xsl:include href="validate_svc_expr.xsl"/>
  <xsl:include href="validate_svc_subr.xsl"/>
  <xsl:include href="validate_svc_phidget.xsl"/>

  <!--
    The id parameter causes processing to start at the first
    (or only) input document element with that ID (see validate_core.xsl).
  -->
  <xsl:param name="id"/>

  <xsl:template match="/">
    <errors>
      <xsl:choose>
        <xsl:when test="$id">
          <xsl:apply-templates select="//*[@id=$id][1]"/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="*"/>
        </xsl:otherwise>
      </xsl:choose>
    </errors>
  </xsl:template>

  <!--
    Main processing template, starting with root element or
    element selected by id parameter if present.
  -->
  <xsl:template match="*">

    <!-- Extension passes -->
    <xsl:call-template name="validate_core"/>
    <xsl:call-template name="validate_instance_spec"/>
    <xsl:call-template name="validate_topology"/>
    <xsl:call-template name="validate_svc_expr"/>
    <xsl:call-template name="validate_svc_subr"/>
    <xsl:call-template name="validate_svc_phidget"/>

    <!-- Recurse -->
    <xsl:apply-templates select="*"/>
  </xsl:template>
</xsl:stylesheet>
