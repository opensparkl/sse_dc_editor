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

  Utility templates for validation transforms.

  This should be included in validate_core.xsl thus:

    <xsl:include href="(path)validate_util.xsl"/>
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsi">

  <!--
    This key holds the generated ids of all elements.
    This is different from any id= attribute that may be present.
    Use with the result of the service-of and clients-of named templates
    to retrieve the element: key('genid',$result)
  -->
  <xsl:key name="genid" match="*" use="generate-id()"/>

  <!--
    Utility template to check list of references.
  -->
  <xsl:template name="check-refs">
    <xsl:param name="role"/>
    <xsl:param name="element"/>
    <xsl:param name="list"/>

    <xsl:variable name="ref"
      select="substring-before(concat($list,' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat($list,' '),' ')"/>

    <xsl:if test="$ref!=''">
      <xsl:if test="not(ancestor::*/*[local-name()=$element][@name=$ref])">
        <warning message="{concat('external_', $role)}"
          value="{$ref}"
          help="trbl_warn_external_role">
          <xsl:call-template name="generate-parent-id"/>
        </warning>
      </xsl:if>

      <xsl:if test="$rest!=''">
        <xsl:call-template name="check-refs">
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="element" select="$element"/>
          <xsl:with-param name="list" select="$rest"/>
        </xsl:call-template>
      </xsl:if>

    </xsl:if>
  </xsl:template>

  <!--
    Utility template to generate the ref= attribute for the context element.
  -->
  <xsl:template name="generate-id">
    <xsl:param name="context" select="."/>
    <xsl:attribute name="context"><xsl:value-of select="local-name($context)"/></xsl:attribute>
    <xsl:attribute name="ref">
      <xsl:choose>
        <xsl:when test="$context/@id">
          <xsl:value-of select="$context/@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id($context)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!--
    Utility template to generate the ref= attribute for the context parent.
  -->
  <xsl:template name="generate-parent-id">
    <xsl:call-template name="generate-id">
      <xsl:with-param name="context" select="parent::*"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Utility template to check mandatory features of an element.
  -->
  <xsl:template name="mandatory">
    <xsl:param name="parents" select="'/ folder mix'"/>
    <xsl:param name="attributes" select="'name'"/>
    <xsl:param name="props"/>
    <xsl:param name="children"/>
    <xsl:param name="precedes"/>

    <xsl:call-template name="mandatory-parents">
      <xsl:with-param name="list" select="$parents"/>
    </xsl:call-template>

    <xsl:call-template name="mandatory-attributes">
      <xsl:with-param name="list" select="$attributes"/>
    </xsl:call-template>

    <xsl:call-template name="mandatory-props">
      <xsl:with-param name="list" select="$props"/>
    </xsl:call-template>

    <xsl:call-template name="mandatory-children">
      <xsl:with-param name="list" select="$children"/>
    </xsl:call-template>

    <xsl:call-template name="mandatory-precedes">
      <xsl:with-param name="list" select="$precedes"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Utility template to check mandatory parents on an element.
    The list can be a '*' to allow any parent.
  -->
  <xsl:template name="mandatory-parents">
    <xsl:param name="list"/>

    <xsl:variable name="name"
      select="substring-before(concat($list,' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat($list,' '),' ')"/>

    <xsl:choose>
      <xsl:when test="$name='/' and not(ancestor::*)"/>
      <xsl:when test="$name='*'"/>
      <xsl:when test="parent::*[local-name()=$name]"/>
      <xsl:when test="$name=''">
        <error message="invalid_parent"
          value="{local-name(parent::*)}"
          help="trbl_err_invalid_parent">
          <xsl:call-template name="generate-id"/>
        </error>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="mandatory-parents">
          <xsl:with-param name="list" select="$rest"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Utility template to check mandatory attributes on an element.
  -->
  <xsl:template name="mandatory-attributes">
    <xsl:param name="list"/>

    <xsl:variable name="name"
      select="substring-before(concat($list,' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat($list,' '),' ')"/>

    <xsl:if test="$name!=''">
      <xsl:if test="not(@*[local-name()=$name])">
        <error message="missing_attribute"
          value="{$name}"
          help="trbl_err_missing_attribute">
          <xsl:call-template name="generate-id"/>
        </error>
      </xsl:if>

      <xsl:call-template name="mandatory-attributes">
        <xsl:with-param name="list" select="$rest"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

  <!--
    Utility template to check mandatory props of an element.
  -->
  <xsl:template name="mandatory-props">
    <xsl:param name="list"/>

    <xsl:variable name="name"
      select="substring-before(concat($list,' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat($list,' '),' ')"/>

    <xsl:if test="$name!=''">
      <xsl:if test="not(prop[@name=$name])">
        <error message="missing_prop"
          value="{$name}">
          <xsl:call-template name="generate-id"/>
        </error>
      </xsl:if>

      <xsl:call-template name="mandatory-props">
        <xsl:with-param name="list" select="$rest"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

  <!--
    Utility template to check mandatory children of an element.
  -->
  <xsl:template name="mandatory-children">
    <xsl:param name="list"/>

    <xsl:variable name="name"
      select="substring-before(concat($list,' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat($list,' '),' ')"/>

    <xsl:if test="$name!=''">
      <xsl:if test="not(*[local-name()=$name])">
        <error message="missing_child"
          value="{$name}"
          help="trbl_err_missing_child">
          <xsl:call-template name="generate-id"/>
        </error>
      </xsl:if>

      <xsl:call-template name="mandatory-children">
        <xsl:with-param name="list" select="$rest"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

  <!--
    Utility template to check an element comes before the listed elements.
  -->
  <xsl:template name="mandatory-precedes">
    <xsl:param name="list"/>

    <xsl:variable name="name"
      select="substring-before(concat($list,' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat($list,' '),' ')"/>

    <xsl:if test="$name!=''">
      <xsl:if test="preceding-sibling::*[local-name()=$name]">
        <error message="wrong_order"
          value="{local-name()}">
          <xsl:call-template name="generate-id"/>
          <xsl:text>Must precede </xsl:text>
          <xsl:value-of select="$name"/>
        </error>
      </xsl:if>

      <xsl:call-template name="mandatory-precedes">
        <xsl:with-param name="list" select="$rest"/>
      </xsl:call-template>

    </xsl:if>

  </xsl:template>

  <!--
    Utility template returns the genid of the service specified in the
    service= attribute on the context element.

    If the provision param is specified, then the genid is returned only
    if the provisioning type matches.

    If the provision param is empty, then the genid is returned
    regardless of provisioning type.
  -->
  <xsl:template name="service-of">
    <xsl:param name="context" select="."/>
    <xsl:param name="provision"/>
    <xsl:choose>
      <xsl:when test="$provision=''">
        <xsl:value-of
          select="generate-id($context/ancestor::*/service[@name=current()/@service])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="generate-id($context/ancestor::*/service[@provision=$provision][@name=current()/@service])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Utility template returns the space-separated list of genids of the clients
    specified in the clients= attribute on the context element.

    If the provision param is specified, then the genid is included in the list
    iff the provision attribute of the client service matches.

    If the provision param is not specified, then the genids of all clients
    are included.
  -->
  <xsl:template name="clients-of">
    <xsl:param name="context" select="."/>
    <xsl:param name="provision"/>

    <xsl:variable name="clients"
      select="concat(' ',normalize-space(@clients),' ')"/>

    <xsl:choose>
      <xsl:when test="$provision=''">
        <xsl:for-each
          select="$context/ancestor::*/service[contains($clients,concat(' ',@name,' '))]">
          <xsl:value-of
            select="generate-id()"/>
          <xsl:if test="position()!=last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>

      <xsl:otherwise>
        <xsl:for-each
          select="$context/ancestor::*/service[contains($clients,concat(' ',@name,' '))][@provision=$provision]">
          <xsl:value-of
            select="generate-id()"/>
          <xsl:if test="position()!=last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Utility template to remove duplicate entries from a list
    of space-separated (field) names.
  -->
  <xsl:template name="de-dup">
    <xsl:param name="list" select="''"/>
    <xsl:param name="acc" select="''"/>

    <xsl:variable name="name"
      select="substring-before(concat(normalize-space($list),' '),' ')"/>

    <xsl:variable name="spaced-name"
      select="concat(' ',$name,' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat(normalize-space($list),' '),' ')"/>

    <xsl:variable name="spaced-acc"
      select="concat(' ',$acc,' ')"/>

    <xsl:choose>
      <xsl:when test="$name=''">
        <xsl:value-of select="$acc"/>
      </xsl:when>

      <xsl:when test="contains($spaced-acc,$spaced-name)">
        <xsl:call-template name="de-dup">
          <xsl:with-param name="list" select="$rest"/>
          <xsl:with-param name="acc" select="$acc"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="de-dup">
          <xsl:with-param name="list" select="$rest"/>
          <xsl:with-param name="acc" select="normalize-space(concat($acc,' ',$name))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Utility template to check there is no intersection between
    the two lists of (field) names.
  -->
  <xsl:template name="no-intersection">
    <xsl:param name="list1" select="''"/>
    <xsl:param name="list2" select="''"/>

    <xsl:variable name="name"
      select="substring-before(concat(normalize-space($list1),' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat(normalize-space($list1),' '),' ')"/>

    <xsl:if test="$name!=''">
      <xsl:if test="contains(concat(' ',$list2,' '),concat(' ',$name,' '))">
        <error message="intersection"
          value="{$name}"
          help="trbl_err_intersection">
          <xsl:call-template name="generate-id"/>
        </error>
      </xsl:if>

      <xsl:call-template name="no-intersection">
        <xsl:with-param name="list1" select="$rest"/>
        <xsl:with-param name="list2" select="$list2"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

  <!--
    Utility template to generate an error if there are duplicates in a list.
  -->
  <xsl:template name="no-duplicates">
    <xsl:param name="list" select="''"/>

    <xsl:variable name="name"
      select="substring-before(concat(normalize-space($list),' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat(normalize-space($list),' '),' ')"/>

    <xsl:if test="$name!=''">
      <xsl:if test="contains(concat($rest,' '),concat($name,' '))">
        <error message="duplicate"
          value="{$name}"
          help="trbl_err_duplicate">
          <xsl:call-template name="generate-parent-id"/>
        </error>
      </xsl:if>

      <xsl:call-template name="no-duplicates">
        <xsl:with-param name="list" select="$rest"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    Utility template to convert a space-separated list of values
    to a list of option elements.
  -->
  <xsl:template name="generate-options">
    <xsl:param name="list" select="''"/>

    <xsl:variable name="name"
      select="substring-before(concat(normalize-space($list),' '),' ')"/>

    <xsl:variable name="rest"
      select="substring-after(concat(normalize-space($list),' '),' ')"/>

    <xsl:if test="$name">
      <option value="{$name}"/>

      <xsl:call-template name="generate-options">
        <xsl:with-param name="list" select="$rest"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    Utility template to produce a space-separated list of the union
    of all reply fields under the given subject.
  -->
  <xsl:template name="reply-field-union">
    <xsl:param name="subject"/>

    <xsl:call-template name="de-dup">
      <xsl:with-param name="list">
        <xsl:for-each select="$subject/reply">
          <xsl:value-of select="@fields"/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!--
    Utility template to produce a space-separated list of field
    names in scope of the subject.

    The type param can be omitted, in which case all fields are
    selected. Otherwise only those whose type matches is included.
  -->
  <xsl:template name="fields-in-scope">
    <xsl:param name="subject"/>
    <xsl:param name="type"/>

    <xsl:call-template name="de-dup">
      <xsl:with-param name="list">
        <xsl:for-each select="ancestor::*/field">
          <xsl:if test="not($type) or ($type=@type)">
            <xsl:value-of select="@name"/>
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!--
    Utility template to generate a hint with a datalist of fields
    in scope of the attribute context, where the fields have the
    supplied type if any.
  -->
  <xsl:template name="hint-fields-in-scope">
    <xsl:param name="type"/>

    <hint message="attribute_value"
      value="{local-name()}">
      <xsl:call-template name="generate-parent-id"/>
      <datalist type="{$type}">
        <xsl:call-template name="generate-options">
          <xsl:with-param name="list">
            <xsl:call-template name="fields-in-scope">
              <xsl:with-param name="subject" select="."/>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </datalist>
    </hint>
  </xsl:template>

  <!--
    Utility template to generate Var=field attribute value hints and
    errors for a prop. By default both the 'inner' (e.g. response) and
    the 'outer' (e.g. solicit) field attributes are used.
  -->
  <xsl:template name="hint-op-fields">
    <xsl:param name="check">
      <xsl:text>inner outer</xsl:text>
    </xsl:param>

    <xsl:param name="msg">
      <msg key="hint-op-fields-1">
        Parameter must specify a field present on the operation.
      </msg>
    </xsl:param>

    <xsl:for-each
      select="@*[contains('ABCDEFGHIJKLMNOPQRSTUVWXYZ',substring(local-name(),1,1))]">

      <xsl:variable name="available-fields">
        <xsl:text> </xsl:text>
        <xsl:call-template name="de-dup">
          <xsl:with-param name="list">
            <xsl:if test="contains($check,'outer')">
              <xsl:value-of select="parent::prop/parent::*/@fields"/>
              <xsl:text> </xsl:text>
            </xsl:if>

            <xsl:if test="contains($check,'inner')">
              <xsl:for-each select="parent::prop/parent::*/*">
                <xsl:value-of select="@fields"/>
                <xsl:text> </xsl:text>
              </xsl:for-each>
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:variable>

      <hint message="attribute_value"
        value="{local-name()}">
        <xsl:call-template name="generate-parent-id"/>
        <datalist>
          <xsl:call-template name="generate-options">
            <xsl:with-param name="list" select="$available-fields"/>
          </xsl:call-template>
        </datalist>
      </hint>

      <xsl:if test="not(contains($available-fields,concat(' ',.,' ')))">
        <error message="invalid_value"
          value="{local-name()}"
          help="trbl_err_invalid_value">
          <xsl:call-template name="generate-parent-id"/>
          <xsl:copy-of select="$msg"/>
        </error>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
