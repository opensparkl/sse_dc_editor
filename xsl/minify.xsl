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

  Minifies the stylesheet provided as the input document.
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!--
    Content of an included stylesheet is processed inline.
  -->
  <xsl:template match="xsl:include">
    <xsl:apply-templates select="document(@href)/xsl:stylesheet/node()"/>
  </xsl:template>

  <!--
    Comments are stripped out.
  -->
  <xsl:template match="comment()"/>

  <!--
    Text nodes inside xsl:text are retained.
  -->
  <xsl:template match="xsl:text/text()">
    <xsl:copy />
  </xsl:template>

  <!--
    Other text nodes are stripped out.
  -->
  <xsl:template match="text()"/>

  <!--
    Message en text is stripped out.
  -->
  <xsl:template match="msg[@key]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Identity transform for everything else.
  -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
