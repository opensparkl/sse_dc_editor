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

  Generates errors, warnings and hints for topological elements.

  This should be included in validate_core.xsl thus:

    <xsl:include href="(path)validate_topology.xsl"/>

  List of help topic IDs:
    api_node_spec
      api_node_spec_type
      api_node_spec_subtype
      api_node_spec_x
      api_node_spec_y
      api_node_spec_lng
      api_node_spec_lat
    api_link_src
      api_link_src_node
    api_link_dst
      api_link_dst_node
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    Extension passes invoked from validate_core.xsl
  -->
  <xsl:template name="validate_topology">
    <xsl:apply-templates select=".|@*" mode="topology_pass_0"/>
    <xsl:apply-templates select=".|@*" mode="topology_pass_1"/>
    <xsl:apply-templates select=".|@*" mode="topology_pass_2"/>
    <xsl:apply-templates select=".|@*" mode="topology_pass_3"/>
  </xsl:template>

  <!--
    TOPOLOGY PASS 0
  -->

  <!-- Node -->
  <xsl:template mode="core_pass0"
    match="node">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name'"/>
      <xsl:with-param name="precedes" select="'field notify solicit request consume folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="node/@name"/>
  <xsl:template mode="core_pass0" match="node/@dependencies"/>
  <xsl:template mode="core_pass0" match="node/@provision"/>

  <!-- Link -->
  <xsl:template mode="core_pass0"
    match="link">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name'"/>
      <xsl:with-param name="props" select="'link.src link.dst'"/>
      <xsl:with-param name="precedes" select="'field notify solicit request consume folder'"/>
    </xsl:call-template>

  </xsl:template>
  <xsl:template mode="core_pass0" match="link/@name"/>
  <xsl:template mode="core_pass0" match="link/@dependencies"/>
  <xsl:template mode="core_pass0" match="link/@provision"/>

  <!--
    TOPOLOGY PASS 1
  -->

  <!--
    Validate node, warn if no spec.
  -->
  <xsl:template mode="topology_pass_1"
    match="node[not(prop[@name='node.spec'])]">
      <warning message="missing_prop"
        value="node.spec"
        help="api_node_spec">
        <xsl:call-template name="generate-id"/>
      </warning>
  </xsl:template>

  <!--
    Hint for node.spec attributes
  -->
  <xsl:template mode="topology_pass_1"
    match="node/prop[@name='node.spec']">
    <xsl:if test="not(@x)">
      <hint message="missing_attribute"
        value="x"
        help="api_node_spec_x">
        <xsl:call-template name="generate-id"/>
      </hint>
    </xsl:if>

    <xsl:if test="not(@y)">
      <hint message="missing_attribute"
        value="y"
        help="api_node_spec_y">
        <xsl:call-template name="generate-id"/>
      </hint>
    </xsl:if>

    <xsl:if test="not(@lat)">
      <hint message="missing_attribute"
        value="lat"
        help="api_node_spec_lat">
        <xsl:call-template name="generate-id"/>
      </hint>
    </xsl:if>

    <xsl:if test="not(@lng)">
      <hint message="missing_attribute"
        value="lng"
        help="api_node_spec_lng">
        <xsl:call-template name="generate-id"/>
      </hint>
    </xsl:if>

    <xsl:if test="not(@type)">
      <warning message="missing_attribute"
        value="type"
        help="api_node_spec_type">
        <xsl:call-template name="generate-id"/>
      </warning>
    </xsl:if>

    <xsl:if test="not(@subtype)">
      <xsl:choose>
        <xsl:when test="@type='simple'">
          <warning message="missing_attribute"
            value="subtype"
            help="api_node_spec_subtype">
            <xsl:call-template name="generate-id"/>
          </warning>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    Node type attribute values.
  -->
  <xsl:template mode="topology_pass_1"
    match="node/prop[@name='node.spec']/@type">
    <hint message="attribute_value"
      value="type">
      <xsl:call-template name="generate-parent-id"/>
      <select default="simple">
        <option value="simple"/>
        <option value="asset"/>
        <option value="segment"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    Node subtype attribute values.
  -->
  <xsl:template mode="topology_pass_1"
    match="node/prop[@name='node.spec']/@subtype">
    <xsl:choose>
      <xsl:when test="parent::prop/@type='simple'">
        <hint message="attribute_value"
          value="subtype">
          <xsl:call-template name="generate-parent-id"/>
          <select default="router">
            <option value="switch"/>
            <option value="router"/>
            <option value="cloud"/>
            <option value="wifi"/>
            <option value="iosv"/>
            <option value="vios"/>
          </select>
        </hint>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    Check link.src and link.dst property attributes are valid, and
    hint for the attribute values.
  -->

<xsl:template mode="topology_pass_1"
    match="link/prop[@name='link.src']|link/prop[@name='link.dst']">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="parents" select="'link'"/>
      <xsl:with-param name="attributes" select="'node'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Hint for node= attribute value on link.src/link.dst.
  -->

  <xsl:template mode="topology_pass_1"
    match="link/prop[@name='link.src']/@node|link/prop[@name='link.dst']/@node">

     <xsl:if test="ancestor::*/node[@name]">
      <hint message="attribute_value"
        value="node">
        <xsl:call-template name="generate-parent-id"/>
        <datalist>
          <xsl:for-each
            select="ancestor::*/node[@name]">
            <option value="{@name}"/>
          </xsl:for-each>
        </datalist>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    TOPOLOGY PASS 2
  -->

  <!--
    Check node is referenced.
  -->
  <xsl:template mode="topology_pass_2"
    match="node">
    <xsl:choose>
      <xsl:when test="parent::*//*[@service=current()/@name]"/>
      <xsl:when test="parent::*//service[@dependency=current()/@name]"/>
      <xsl:when test="parent::*//*[contains(concat(@clients,' '),concat(current()/@name,' '))]"/>
      <xsl:when test="parent::*//link/prop[@name='link.src'][@node=current()/@name]"/>
      <xsl:when test="parent::*//link/prop[@name='link.dst'][@node=current()/@name]"/>
      <xsl:otherwise>
        <warning message="not_referenced">
          <xsl:call-template name="generate-id"/>
        </warning>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Check link.src and link.dst node attribute points to valid node.
  -->
  <xsl:template mode="topology_pass_2"
    match="link/prop[@node]">
    <xsl:variable name="node"
      select="ancestor::*/node[@name=current()/@node][1]"/>

    <xsl:choose>
      <xsl:when test="$node">
        <xsl:if test="@prop and not($node/prop[@name=current()/@prop])">
          <error message="invalid_interface"
            value="{@prop}">
            <xsl:call-template name="generate-id"/>
          </error>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <warning message="external_node"
          value="{@node}">
          <xsl:call-template name="generate-id"/>
        </warning>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    TOPOLOGY PASS 3
  -->

  <!--
    Hint for link.src/link.dst prop attribute and values.
  -->
  <xsl:template mode="topology_pass_3"
    match="link/prop[@name='link.src']|link/prop[@name='link.dst']">

    <xsl:variable name="interfaces"
      select="ancestor::*/node[@name=current()/@node][1]/prop[@name!='node.spec']"/>

    <xsl:choose>
      <xsl:when test="@prop and $interfaces">
        <hint message="attribute_value"
          value="prop">
          <xsl:call-template name="generate-id"/>
          <datalist>
            <xsl:for-each
              select="$interfaces">
              <option value="{@name}"/>
            </xsl:for-each>
          </datalist>
        </hint>
      </xsl:when>

      <xsl:when test="not(@prop) and $interfaces">
        <hint message="missing_attribute"
          value="prop">
          <xsl:call-template name="generate-id"/>
        </hint>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    The default rule in each mode generates no error or warning,
    and has lowest priority.
  -->
  <xsl:template match="node()|@*" mode="topology_pass_0" priority="-1"/>
  <xsl:template match="node()|@*" mode="topology_pass_1" priority="-1"/>
  <xsl:template match="node()|@*" mode="topology_pass_2" priority="-1"/>
  <xsl:template match="node()|@*" mode="topology_pass_3" priority="-1"/>

</xsl:stylesheet>
