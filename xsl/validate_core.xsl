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

  IMPORTANT NOTES:
    1. NEVER use the current() function in a template match specification!
    2. NEVER specify a with-param value as text content, always use select=

  Transforms SPARKL source into a complete list of errors, warnings and hints.
  The source is valid and can be deployed if the list contains only warnings
  and hints.

  An error looks like this (value is optional):

    <error
      ref="SOME_ELEMENT_ID"
      context="SOME_ELEMENT_TAG"
      message="missing_attribute"
      value="name_of_attribute"/>

  A warning looks like this (value is optional):

    <warning
      ref="SOME_ELEMENT_ID"
      context="SOME_ELEMENT_TAG"
      message="missing_attribute"
      value="name_of_attribute"/>

  A hint looks like this:

    <hint
      ref="SOME_ELEMENT_ID"
      context="SOME_ELEMENT_TAG"
      message="missing_attribute"
      value="name_of_attribute"/>

  The ref will use the id= attribute from the source element, if present.
  Otherwise it will create a id which is the same for all errors
  and warnings on that element.

  Any one node can be considered once per pass, as specified in the mode.
  The number of passes is arbitrary, but has to be explicit.

  Make sure no node is matched by more than 1 template in a given pass.

  If you don't manage this, then only the first error on that node will be
  shown. That isn't necessarily too bad, since when the user corrects that
  first error, the next one will be shown (if any).
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    Core passes.
  -->
  <xsl:template name="validate_core">
    <xsl:apply-templates select=".|@*" mode="core_pass0"/>
    <xsl:apply-templates select=".|@*" mode="core_pass1"/>
    <xsl:apply-templates select=".|@*" mode="core_pass2"/>
    <xsl:apply-templates select=".|@*" mode="core_pass3"/>
    <xsl:apply-templates select=".|@*" mode="core_pass4"/>
    <xsl:apply-templates select=".|@*" mode="core_pass5"/>
    <xsl:apply-templates select=".|@*" mode="core_pass6"/>
  </xsl:template>

  <!--
    PASS 0
  -->

  <!-- Folder -->
  <xsl:template mode="core_pass0" match="folder"/>
  <xsl:template mode="core_pass0" match="folder/@name"/>

  <!-- Mix -->
  <xsl:template mode="core_pass0" match="mix"/>
  <xsl:template mode="core_pass0" match="mix/@name"/>

  <!-- Service -->
  <xsl:template mode="core_pass0" match="service">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name'"/>
      <xsl:with-param name="precedes" select="'field notify solicit request consume folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="service/@name"/>
  <xsl:template mode="core_pass0" match="service/@dependencies"/>
  <xsl:template mode="core_pass0" match="service/@provision"/>

  <!-- Field -->
  <xsl:template mode="core_pass0" match="field">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name'"/>
      <xsl:with-param name="precedes" select="'notify solicit request consume folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="field/@name"/>
  <xsl:template mode="core_pass0" match="field/@type"/>

  <!-- Notify -->
  <xsl:template mode="core_pass0" match="notify">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name service fields'"/>
      <xsl:with-param name="precedes" select="'folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="notify/@name"/>
  <xsl:template mode="core_pass0" match="notify/@clients"/>
  <xsl:template mode="core_pass0" match="notify/@service"/>
  <xsl:template mode="core_pass0" match="notify/@value"/>
  <xsl:template mode="core_pass0" match="notify/@fields"/>

  <!-- Solicit -->
  <xsl:template mode="core_pass0" match="solicit">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name service fields'"/>
      <xsl:with-param name="children" select="'response'"/>
      <xsl:with-param name="precedes" select="'folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="solicit/@name"/>
  <xsl:template mode="core_pass0" match="solicit/@clients"/>
  <xsl:template mode="core_pass0" match="solicit/@service"/>
  <xsl:template mode="core_pass0" match="solicit/@value"/>
  <xsl:template mode="core_pass0" match="solicit/@fields"/>

  <!-- Response -->
  <xsl:template mode="core_pass0" match="response">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="parents" select="'solicit'"/>
      <xsl:with-param name="attributes" select="'name fields'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="response/@name"/>
  <xsl:template mode="core_pass0" match="response/@fields"/>
  <xsl:template mode="core_pass0" match="response/@mask"/>
  <xsl:template mode="core_pass0" match="response/@value"/>

  <!-- Request -->
  <xsl:template mode="core_pass0" match="request">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name service fields'"/>
      <xsl:with-param name="children" select="'reply'"/>
      <xsl:with-param name="precedes" select="'folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="request/@name"/>
  <xsl:template mode="core_pass0" match="request/@service"/>
  <xsl:template mode="core_pass0" match="request/@value"/>
  <xsl:template mode="core_pass0" match="request/@fields"/>
  <xsl:template mode="core_pass0" match="request/@mask"/>

  <!-- Reply -->
  <xsl:template mode="core_pass0" match="reply">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="parents" select="'request consume'"/>
      <xsl:with-param name="attributes" select="'name fields'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="reply/@name"/>
  <xsl:template mode="core_pass0" match="reply/@fields"/>
  <xsl:template mode="core_pass0" match="reply/@value"/>

  <!-- Consume -->
  <xsl:template mode="core_pass0" match="consume">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="attributes" select="'name service fields'"/>
      <xsl:with-param name="precedes" select="'folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="consume/@name"/>
  <xsl:template mode="core_pass0" match="consume/@service"/>
  <xsl:template mode="core_pass0" match="consume/@value"/>
  <xsl:template mode="core_pass0" match="consume/@fields"/>
  <xsl:template mode="core_pass0" match="consume/@mask"/>

  <!-- Grant can go under folder or mix -->
  <xsl:template mode="core_pass0" match="grant">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="parents" select="'folder mix'"/>
      <xsl:with-param name="attributes" select="'permission to'"/>
      <xsl:with-param name="precedes" select="'service field notify solicit request consume folder'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="grant/@permission"/>
  <xsl:template mode="core_pass0" match="grant/@to"/>

  <!-- Prop can go in any element and have any attribute -->
  <xsl:template mode="core_pass0" match="prop">
    <xsl:call-template name="mandatory">
      <xsl:with-param name="parents" select="'*'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="core_pass0" match="prop/@*"/>
  <xsl:template mode="core_pass0" match="prop/text()"/>

  <!-- Id attribute is always valid -->
  <xsl:template mode="core_pass0" match="@id"/>

  <!-- Other namespaces are valid -->
  <xsl:template mode="core_pass0" match="*[namespace-uri()!='']"/>
  <xsl:template mode="core_pass0" match="@*[namespace-uri()!='']"/>

  <!-- No other element is valid -->
  <xsl:template mode="core_pass0" match="*">
    <error message="invalid_element"
      value="{local-name()}">
      <xsl:call-template name="generate-parent-id"/>
    </error>
  </xsl:template>

  <!-- No other attribute is valid -->
  <xsl:template mode="core_pass0" match="@*">
    <error message="invalid_attribute"
      value="{local-name()}">
      <xsl:call-template name="generate-parent-id"/>
    </error>
  </xsl:template>

  <!--
    PASS 1
  -->

  <!--
    Check all attributes are non-empty and normalised
  -->
  <xsl:template mode="core_pass1" match="@*[.='']">
    <error message="empty_attribute"
      value="{local-name()}">
      <xsl:call-template name="generate-parent-id"/>
    </error>
  </xsl:template>

  <!--
    Check name attributes look right. Can't use regex unfortunately.
    See sse_cfg.hrl
  -->
  <xsl:template mode="core_pass1" match="@name">
    <xsl:choose>
      <xsl:when test="string-length(.) &gt; 64">
        <error message="name_too_long"
          value="{.}">
          <xsl:call-template name="generate-parent-id"/>
        </error>
      </xsl:when>

      <xsl:when test="contains(.,' ')">
        <error message="name_contains_space"
          value="{.}">
          <xsl:call-template name="generate-parent-id"/>
        </error>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    Check all element names are unique under their parent.
  -->
  <xsl:template mode="core_pass1" match="*[@name]">
    <xsl:if test="preceding-sibling::*[@name=current()/@name]">
      <error message="duplicate_name">
        <xsl:call-template name="generate-id"/>
      </error>
    </xsl:if>
  </xsl:template>

  <!--
    PASS 2
  -->

  <!--
    Check any service attribute is a valid reference.
  -->
  <xsl:template mode="core_pass2" match="@service">
    <xsl:choose>
      <xsl:when test="ancestor::*/service[@name=current()]"/>
      <xsl:when test="ancestor::*/node[@name=current()]"/>
      <xsl:when test="ancestor::*/link[@name=current()]"/>
      <xsl:otherwise>
        <warning message="external_service"
          value="{.}"
          help="trbl_warn_external_service">
          <xsl:call-template name="generate-parent-id"/>
        </warning>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Check any fields attribute are valid references.
  -->
  <xsl:template mode="core_pass2" match="@fields">
    <xsl:call-template name="check-refs">
      <xsl:with-param name="role" select="'field'"/>
      <xsl:with-param name="element" select="'field'"/>
      <xsl:with-param name="list" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Check any mask fields attribute are valid references.
  -->
   <xsl:template mode="core_pass2" match="@mask">
    <xsl:call-template name="check-refs">
      <xsl:with-param name="role" select="'field'"/>
      <xsl:with-param name="element" select="'field'"/>
      <xsl:with-param name="list" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Check field type attributes are correct.
  -->
  <xsl:template mode="core_pass2" match="field/@type[.='binary']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='boolean']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='float']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='integer']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='json']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='string']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='term']"/>
  <xsl:template mode="core_pass2" match="field/@type[.='utf8']"/>
  <xsl:template mode="core_pass2" priority="0" match="field/@type">
    <error message="invalid_type"
      value="{.}"
      help="trbl_err_invalid_type">
      <xsl:call-template name="generate-parent-id"/>
    </error>
  </xsl:template>

  <!--
    Check service dependencies are valid.
  -->
  <xsl:template mode="core_pass2" match="@dependencies">
    <xsl:call-template name="check-refs">
      <xsl:with-param name="role" select="'dependency'"/>
      <xsl:with-param name="element" select="'service'"/>
      <xsl:with-param name="list" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Check clients are valid.
  -->
  <xsl:template mode="core_pass2" match="@clients">
    <xsl:call-template name="check-refs">
      <xsl:with-param name="role" select="'client'"/>
      <xsl:with-param name="element" select="'service'"/>
      <xsl:with-param name="list" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Check operations are under a mix.
  -->
  <xsl:template mode="core_pass2" match="notify|solicit|request|consume">
    <xsl:if test="not(ancestor::mix)">
      <warning message="no_mix"
        help="trbl_warn_no_mix">
        <xsl:call-template name="generate-id"/>
      </warning>
    </xsl:if>
  </xsl:template>

  <!--
    Check reply field names do not intersect with request.
  -->
  <xsl:template mode="core_pass2" match="request/reply">
    <xsl:call-template name="no-intersection">
      <xsl:with-param name="list1" select="parent::request/@fields"/>
      <xsl:with-param name="list2" select="@fields"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Warn if service is missing provision attribute.
  -->
  <xsl:template mode="core_pass2" match="service[not(@provision)]">
    <warning message="missing_attribute"
      value="provision"
      help="trbl_warn_missing_attribute">
      <xsl:call-template name="generate-id"/>
    </warning>
  </xsl:template>

  <!--
    Hint for content-type= attribute on all prop.
  -->
  <xsl:template mode="core_pass2" match="prop[not(@content-type)]">
    <hint message="missing_attribute"
      value="content-type">
      <xsl:call-template name="generate-id"/>
    </hint>
  </xsl:template>

  <!--
    Default list of prop content-type= attribute values.
    Override this template to have a different or constrained list.
  -->
  <xsl:template mode="core_pass2" match="prop/@content-type" priority="-5">
    <hint message="attribute_value"
      value="content-type">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="text/x-erlang"/>
        <option value="text/x-markdown"/>
        <option value="text/x-python"/>
        <option value="text/plain"/>
        <option value="application/xml"/>
        <option value="application/json"/>
        <option value="application/javascript"/>
      </select>
    </hint>
  </xsl:template>

  <!--
    PASS 3
  -->

  <!--
    Check service is referenced.
  -->
  <xsl:template mode="core_pass3" match="service">
    <xsl:choose>
      <xsl:when test="parent::*//*[@service=current()/@name]"/>
      <xsl:when test="parent::*//*[contains(concat(@dependencies,' '),concat(current()/@name,' '))]"/>
      <xsl:when test="parent::*//*[contains(concat(@clients,' '),concat(current()/@name,' '))]"/>
      <xsl:otherwise>
          <warning message="not_referenced"
            help="trbl_warn_service_not_referenced">
            <xsl:call-template name="generate-id"/>
          </warning>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Check field is referenced.
  -->
  <xsl:template mode="core_pass3" match="field">
    <xsl:choose>
      <xsl:when test="parent::*//*[contains(concat(@fields,' '),concat(current()/@name,' '))]"/>
      <xsl:otherwise>
        <warning message="not_referenced"
          help="trbl_warn_field_not_referenced">
          <xsl:call-template name="generate-id"/>
        </warning>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Check no duplicate references in fields and clients attributes.
  -->
  <xsl:template mode="core_pass3" match="@fields|@clients">
    <xsl:call-template name="no-duplicates">
      <xsl:with-param name="list" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Hint when an operation subject has no value attribute.
  -->
  <xsl:template mode="core_pass3" match="notify|solicit|response|request|reply|consume">
    <xsl:if test="not(@value)">
      <hint message="missing_attribute"
        value="value">
        <xsl:call-template name="generate-id"/>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    PASS 4
  -->

  <!--
    Hint when a service has no dependencies declared.
  -->
  <xsl:template mode="core_pass4" match="service[not(@dependencies)]">
    <hint message="missing_attribute"
      value="dependencies">
      <xsl:call-template name="generate-id"/>
    </hint>
  </xsl:template>

  <!--
    Error when fields and mask attributes intersect.
  -->
  <xsl:template mode="core_pass4" match="request|consume|response">
    <xsl:call-template name="no-intersection">
      <xsl:with-param name="list1" select="@fields"/>
      <xsl:with-param name="list2" select="@mask"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    PASS 5
  -->


  <!--
    Hint for timeout prop on services and to/fro ops.
  -->
  <xsl:template mode="core_pass5" match="service|solicit|request|consume[reply]">
    <xsl:if test="not(prop[@name='timeout'])">
      <hint message="missing_prop"
        value="timeout">
        <xsl:call-template name="generate-id"/>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    Hint for value= attribute on timeout prop.
  -->
  <xsl:template mode="core_pass5" match="prop[@name='timeout'][not(@value)]">
    <hint message="missing_attribute"
      value="value">
      <xsl:call-template name="generate-id"/>
    </hint>
  </xsl:template>

  <!--
    Options list for value= attribute on timeout prop.
  -->
  <xsl:template mode="core_pass5" match="prop[@name='timeout']/@value">
    <hint message="attribute_value"
      value="value">
      <xsl:call-template name="generate-parent-id"/>
      <datalist>
        <option value="5s"/>
        <option value="30s"/>
        <option value="30m"/>
        <option value="1h"/>
        <option value="1d"/>
        <option value="1w"/>
        <option value="1y"/>
        <option value="infinity"/>
      </datalist>
    </hint>
  </xsl:template>

  <!--
    PASS 6
  -->

  <!--
    Hint for params property on all event types.
  -->
  <xsl:template mode="core_pass6"
    match="notify|solicit|response|request|reply|consume">
    <xsl:if test="not(prop[@name='params'])">
      <hint
        message="missing_prop"
        value="params">
        <xsl:call-template name="generate-id"/>
        <msg key="prop_params">
        Text content in the form 'param1:field1 param2:field2'. Use to
        locally override field names in this operation.
        </msg>
      </hint>
    </xsl:if>
  </xsl:template>

  <!--
    Override params prop content-type= options.
  -->
  <xsl:template mode="core_pass2" match="prop[@name='params']/@content-type">
    <hint message="attribute_value"
      value="content-type">
      <xsl:call-template name="generate-parent-id"/>
      <select>
        <option value="text/plain"/>
      </select>
    </hint>
  </xsl:template>


  <!--
    ADD MORE PASSES HERE IF AND WHEN NECESSARY.
  -->

  <!--
    DEFAULTS FOR ALL PASSES.
  -->

  <!--
    The default rule in each mode generates no error or warning,
    and has lowest priority.
  -->
  <xsl:template match="node()|@*" mode="core_pass0" priority="-10"/>
  <xsl:template match="node()|@*" mode="core_pass1" priority="-10"/>
  <xsl:template match="node()|@*" mode="core_pass2" priority="-10"/>
  <xsl:template match="node()|@*" mode="core_pass3" priority="-10"/>
  <xsl:template match="node()|@*" mode="core_pass4" priority="-10"/>
  <xsl:template match="node()|@*" mode="core_pass5" priority="-10"/>
  <xsl:template match="node()|@*" mode="core_pass6" priority="-10"/>

</xsl:stylesheet>
