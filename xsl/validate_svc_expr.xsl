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

  Generates errors, warnings and hints for svc_expr elements.

  This should be included in validate_core.xsl thus:

    <xsl:include href="(path)validate_svc_expr.xsl"/>

  List of help topic IDs:
    api_expr_auto
    api_expr_auto_count
    api_expr_auto_interval
    api_expr_bind_in
    api_expr_bind_out
    api_expr_src
    api_expr_state
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    Extension passes invoked from validate_core.xsl
  -->
  <xsl:template name="validate_svc_expr">
    <xsl:apply-templates select=".|@*" mode="svc_expr_pass_0"/>
    <xsl:apply-templates select=".|@*" mode="svc_expr_pass_1"/>
  </xsl:template>

  <!--
    PASS 0
  -->

  <!--
    Validate service.
  -->
  <xsl:template mode="svc_expr_pass_0"
    match="*[@provision='expr']">

    <xsl:if test="not(prop[@name='expr.src'])">
      <hint message="missing_prop"
        value="expr.src"
        help="api_expr_src">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_1">
          This prop contains <b>Erlang</b> expressions which
          are evaluated once on service start.
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(prop[@name='expr.state'])">
      <hint message="missing_prop"
        value="expr.state"
        help="api_expr_state">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_2">
          Each attribute on this prop defines a state variable
          and the variable used to update it, e.g.
          <code>Var="NewVar"</code>
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(prop[@name='expr.init'])">
      <hint message="missing_prop"
        value="expr.init"
        help="api_expr_init">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_2_1">
          Each Var attribute on this prop defines an initial
          state or static value, with no terminating period.
        </msg>
      </hint>
    </xsl:if>

    <hint message="missing_prop"
      value="expr.init.Var"
      help="api_expr_init_var">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_expr_2_2">
        Use <code>expr.init.Var</code> prop content to initialise
        a Var with a long value term, such as a list or map, with no
        terminating period.
      </msg>
    </hint>
  </xsl:template>

  <!--
    Validate a notify whose clients include svc_expr service.
  -->
  <xsl:template mode="svc_expr_pass_1"
    match="notify">

    <xsl:variable name="expr_clients">
      <xsl:call-template name="clients-of">
        <xsl:with-param name="provision" select="'expr'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$expr_clients!=''">
      <xsl:if test="not(prop[@name='expr.state']) and not(prop[@name='expr.auto'])">
        <hint message="missing_prop"
          value="expr.auto"
          help="api_expr_auto">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_expr_11">
            Triggered once on client service start. Use <code>count</code>
            and <code>interval</code> attributes for repeated triggering.
            Fires an actual notify <b>only</b> if the <code>expr.src</code>
            expression evaluates to <code>true</code>.
          </msg>
        </hint>
      </xsl:if>

      <xsl:if test="not(prop[@name='expr.auto']) and not(prop[@name='expr.state'])">
        <hint message="missing_prop"
          value="expr.state"
          help="api_expr_state">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_expr_11a">
            Specify state variables whose change triggers this notify.
          </msg>
        </hint>
      </xsl:if>

      <xsl:if test="not(prop[@name='expr.src'])">
        <hint message="missing_prop"
          value="expr.src"
          help="api_expr_src">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_expr_12">
            When triggered, if these expressions evaluate to true then
            the notify event is fired.
          </msg>
        </hint>
      </xsl:if>
    </xsl:if>

  </xsl:template>

  <!--
    Validate request/consume whose service is svc_expr.
  -->
  <xsl:template mode="svc_expr_pass_0"
    match="request|consume">

    <xsl:variable name="expr-service-of">
      <xsl:call-template name="service-of">
        <xsl:with-param name="provision" select="'expr'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$expr-service-of!=''">

      <xsl:if test="not(prop[@name='expr.src'])">
        <hint message="missing_prop"
          value="expr.src"
          help="api_expr_src">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_expr_3">
            This prop contains the <b>Erlang</b> expressions to
            be evaluated on each invocation of the operation.
          </msg>
        </hint>
      </xsl:if>
    </xsl:if>

  </xsl:template>

  <!--
    Prompt for Var="NewVar" attributes on expr.state prop.
  -->
  <xsl:template mode="svc_expr_pass_0"
    match="prop[@name='expr.state']">

    <hint message="missing_attribute"
      value="StateVar{count(@*)-1}">
      <xsl:call-template name="generate-id"/>
      <xsl:choose>
        <xsl:when test="parent::notify">
          <msg key="validate_svc_expr_6a">
            Use to indicate a state variable and its old value,
            e.g. <code>StateVar="OldStateVar"</code>
          </msg>
        </xsl:when>
        <xsl:otherwise>
          <msg key="validate_svc_expr_6b">
            Use to indicate a state variable and its new value,
            e.g. <code>StateVar="NewStateVar"</code>
          </msg>
        </xsl:otherwise>
      </xsl:choose>
    </hint>
  </xsl:template>

  <!--
    Validate expr.src prop. Warning if no content, error if there is
    content but it is not terminated by a period.
  -->
  <xsl:template mode="svc_expr_pass_0"
    match="prop[@name='expr.src']">

    <xsl:if test="not(text())">
      <warning message="missing_content"
        help="trbl_warn_missing_content_expr_src">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_7">
          Should contain an Erlang expression list.
          Remember var names must start with a Cap.
          e.g. <code>
            Value = get("fieldA"),
            put("fieldB", Value+1),
            "Ok".
          </code>
        </msg>
      </warning>
    </xsl:if>

    <xsl:if test="text()">
      <xsl:variable name="norm" select="normalize-space(text())"/>
      <xsl:if test="substring($norm,string-length($norm),1)!='.'">
        <error message="invalid_content"
          help="trbl_err_invalid_content">
          <xsl:call-template name="generate-id"/>
          <msg key="validate_svc_expr_8">
            Last Erlang expression must be followed by a period.
          </msg>
        </error>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--
    Validate expr.init short init vars prop
  -->
  <xsl:template mode="svc_expr_pass_0"
    match="prop[@name='expr.init']">

    <hint message="missing_attribute"
      value="Var{count(@*)-1}">
      <xsl:call-template name="generate-id"/>
      <msg key="validate_svc_expr_10_1">
        Attribute name is variable name, must start with Cap.
        e.g. <code>Var="term"</code>
      </msg>
    </hint>
  </xsl:template>

  <!--
    Validate expr.init.Var long init var prop
  -->
  <xsl:template mode="svc_expr_pass_0"
    match="prop[starts-with(@name,'expr.init.')]">

    <xsl:if test="not(text())">
      <warning message="missing_content"
        help="trbl_warn_missing_content_expr_init_var">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_10_2">
          Should contain an Erlang term.
          Don't terminate with period.
          e.g. <code>
            #{foo => bar}
          </code>
        </msg>
      </warning>
    </xsl:if>
  </xsl:template>

  <!--
    PASS 1
  -->

  <!--
    Validate expr.auto prop on notify operation only.
  -->
  <xsl:template mode="svc_expr_pass_1"
    match="notify/prop[@name='expr.auto']">

    <xsl:if test="not(@count)">
      <hint message="missing_attribute"
        value="count"
        help="api_expr_auto_count">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_13">
          If omitted, default count is -1.
          e.g. <code>count="5"</code>
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(@interval)">
      <hint message="missing_attribute"
        value="interval"
        help="api_expr_auto_interval">
        <xsl:call-template name="generate-id"/>
        <msg key="validate_svc_expr_14">
          If omitted, default interval is 30s.
          e.g. <code>interval="5s"</code>
        </msg>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    Override expr.src prop content-type= options from validate_core.
  -->
  <xsl:template mode="core_pass2" match="prop[@name='expr.src']/@content-type">
    <hint message="attribute_value"
      value="content-type">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="text/x-erlang"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    Override expr.init.Var prop content-type= options from validate_core.
  -->
  <xsl:template mode="core_pass2"
    match="prop[starts-with(@name,'expr.init.')]/@content-type">
    <hint message="attribute_value"
      value="content-type">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="text/x-erlang"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    The default rule in each mode generates no error or warning,
    and has lowest priority.
  -->
  <xsl:template match="node()|@*" mode="svc_expr_pass_0" priority="-1"/>
  <xsl:template match="node()|@*" mode="svc_expr_pass_1" priority="-1"/>

</xsl:stylesheet>
