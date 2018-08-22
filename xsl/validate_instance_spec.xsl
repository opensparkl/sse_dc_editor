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

  Validation templates for instance.spec on any service and
  for instance.bind on any operation.
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    Core passes.
  -->
  <xsl:template name="validate_instance_spec">
    <xsl:apply-templates select=".|@*" mode="instance_spec_pass0"/>
    <xsl:apply-templates select=".|@*" mode="instance_spec_pass1"/>
  </xsl:template>

  <!--
    Hint if service is missing an instance.spec prop.
  -->
  <xsl:template mode="instance_spec_pass0" match="service[not(prop[@name='instance.spec'])]">
    <hint message="missing_prop"
      value="instance.spec"
      help="api_instance_spec">
      <xsl:call-template name="generate-id"/>
      <msg key="instance-spec">
          (Optional) Use it to control service instantiation.
        </msg>
    </hint>
  </xsl:template>

  <!--
    Hint if instance.spec prop is missing domains= attribute or
    dispatch= attribute.
  -->
  <xsl:template mode="instance_spec_pass0" match="service/prop[@name='instance.spec']">
    <xsl:if test="not(@onopen)">
      <hint message="missing_attribute"
        value="onopen"
        help="api_instance_spec_onopen">
        <xsl:call-template name="generate-id"/>
        <msg key="instance-spec-onopen">
          (Optional) Relative path to notify or solicit with json 'event' field.
        </msg>
      </hint>
    </xsl:if>

     <xsl:if test="not(@onclose)">
      <hint message="missing_attribute"
        value="onopen"
        help="api_instance_spec_onclose">
        <xsl:call-template name="generate-id"/>
        <msg key="instance-spec-onclose">
          (Optional) Relative path to notify or solicit with json 'event' field.
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(@node)">
      <hint message="missing_attribute"
        value="node"
        help="api_instance_spec_node">
        <xsl:call-template name="generate-id"/>
        <msg key="instance-spec-node">
          (Optional) Node on which service must be instantiated.
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(@domains)">
      <hint message="missing_attribute"
        value="domains"
        help="api_instance_spec_domains">
        <xsl:call-template name="generate-id"/>
        <msg key="instance-spec-domains">
          (Optional) Space-separated list of domains on which service can
          be instantiated. Ignored if node= is specified.
        </msg>
      </hint>
    </xsl:if>

    <xsl:if test="not(@ttl)">
      <hint message="missing_attribute"
        value="ttl"
        help="api_instance_spec_ttl">
        <xsl:call-template name="generate-id"/>
        <msg key="instance-spec-ttl">
          (Optional) Inactive TTL after which instance is stopped
          automatically.
        </msg>
      </hint>
    </xsl:if>

    <hint message="missing_attribute"
      value="Var{count(@*[not(contains('name node domains ttl content-type',local-name()))])}"
      help="api_instance_spec_var">
      <xsl:call-template name="generate-id"/>
      <msg key="instance-spec-param">
        (Optional) Var="default_term" parameter.
        Override with instance.bind on operations
      </msg>
    </hint>
  </xsl:template>

  <!--
    Hint for instance.spec prop dispatch= attribute value.
  -->
  <xsl:template mode="instance_spec_pass0" match="service/prop[@name='instance.spec']/@dispatch">
    <hint message="attribute_value"
      value="dispatch">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="local"/>
        <option value="distributed"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    Hint for instance.bind prop on operations.
  -->
  <xsl:template mode="instance_spec_pass0" match="*[@service]">
    <hint message="missing_prop"
      value="instance.bind"
      help="api_instance_bind">
      <xsl:call-template name="generate-id"/>
      <msg key="instance-bind">
        (Optional) Bind instance.spec Vars to operation field values.
      </msg>
    </hint>
  </xsl:template>

  <!--
    Hint for instance.bind prop Var= attribute on operations.
  -->
  <xsl:template mode="instance_spec_pass0" match="prop[@name='instance.bind']">
    <hint message="missing_attribute"
      value="Var{count(@*[not(contains('name content-type',local-name()))])}"
      help="api_instance_bind_var">
      <xsl:call-template name="generate-id"/>
      <msg key="instance-bind-var">
        (Optional) Var="field" where Var matches instance.spec Var on service.
      </msg>
    </hint>

    <xsl:call-template name="hint-op-fields">
      <xsl:with-param name="check" select="'outer'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    OVERRIDES
  -->

  <!--
    Override prop instance.spec content-type= value.
  -->
  <xsl:template mode="core_pass2"
    match="prop[@name='instance.spec']/@content-type">
     <hint message="attribute_value"
      value="content-type">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="text/x-erlang"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    DEFAULTS FOR ALL PASSES.
  -->

  <!--
    The default rule in each mode generates no error or warning,
    and has lowest priority.
  -->
  <xsl:template match="node()|@*" mode="instance_spec_pass0" priority="-10"/>
  <xsl:template match="node()|@*" mode="instance_spec_pass1" priority="-10"/>


</xsl:stylesheet>
