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

  Transforms XML into HTML suitable for rendering.
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:apply-templates>
      <xsl:with-param name="level" select="0"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    Element with no content, only attributes.
  -->
  <xsl:template match="*[not(child::node())]">
    <xsl:param name="level"/>

    <xsl:call-template name="indent">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>

    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>

    <xsl:apply-templates select="@*"/>

    <xsl:text>/&gt;</xsl:text>
  </xsl:template>

  <!--
    Element with non-text children.
  -->
  <xsl:template match="*[*]">
    <xsl:param name="level"/>

    <xsl:call-template name="indent">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>

    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>

    <xsl:apply-templates select="@*"/>

    <xsl:text>&gt;</xsl:text>

    <xsl:apply-templates select="node()">
      <xsl:with-param name="level" select="$level+1"/>
    </xsl:apply-templates>

    <xsl:call-template name="indent">
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="force-nl" select="true()"/>
    </xsl:call-template>

    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt;</xsl:text>

  </xsl:template>

  <!--
    Element with text children only.
  -->
  <xsl:template match="*[not(*)][text()]">
    <xsl:param name="level"/>

    <xsl:call-template name="indent">
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>

    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>

    <xsl:apply-templates select="@*"/>

    <xsl:text>&gt;</xsl:text>

    <xsl:apply-templates select="text()"/>

    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>&gt;</xsl:text>

  </xsl:template>

  <!--
    Attribute.
  -->
  <xsl:template match="@*">
    <xsl:text> </xsl:text>
    <xsl:value-of select="local-name()"/>

    <xsl:text>=</xsl:text>

    <xsl:text>"</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>

  </xsl:template>

  <!--
    Text
  -->
  <xsl:template match="prop/text()">
    <xsl:text>&lt;![CDATA[</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>]]&gt;</xsl:text>
  </xsl:template>

  <!--
    Indent.
  -->
  <xsl:template name="indent">
    <xsl:param name="level"/>
    <xsl:param name="force-nl" select="false()"/>
    <xsl:variable name="spaces"
      select="'                                                           '"/>

    <xsl:if test="$force-nl or $level > 0">
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:value-of select="substring($spaces, 1, 2*$level)"/>
  </xsl:template>

</xsl:stylesheet>
