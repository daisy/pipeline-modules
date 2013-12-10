<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="output-ns" />
  <xsl:param name="skippable-tags" />
  <xsl:param name="output-subsentence-tag" />
  <xsl:param name="can-contain-subsentences" />

  <xsl:variable name="skippable-tag-list" select="concat(',', $skippable-tags, ',')" />

  <xsl:template match="@*|node()" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[collection()/d:sentences/*[@id = current()/@id]]" priority="2">
    <xsl:choose>
      <xsl:when test="count(descendant::*[contains($skippable-tag-list, local-name())]) = 0 ">
	<xsl:apply-templates select="." mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="." mode="split"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()" mode="copy" priority="1">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="*" mode="copy" priority="2">
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="copy"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()" mode="split" priority="1">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="split"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="ok-parent-list" select="concat(',', $can-contain-subsentences, ',')" />
  <xsl:template match="*[contains($ok-parent-list, local-name())]" mode="split" priority="2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each-group select="node()" group-adjacent="not(descendant-or-self::*[contains($skippable-tag-list, local-name())])">
	<xsl:choose>
	  <xsl:when test="current-grouping-key()">
	    <!-- if no skippable element is found in this neighbourhood, then -->
	    <!-- all the neighbors are grouped together under the same node -->
	    <xsl:element name="{$output-subsentence-tag}" namespace="{$output-ns}">
	      <xsl:attribute name="id">
		<xsl:value-of select="concat('sub-', generate-id())" />
	      </xsl:attribute>
	      <xsl:apply-templates select="current-group()" mode="copy"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="current-group()" mode="split"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[contains($skippable-tag-list, local-name())]" mode="split" priority="3">
    <xsl:choose>
      <xsl:when test="(@id or (../@id and count(../node()) = 1)) or not(contains($ok-parent-list, local-name()))">
	<xsl:apply-templates select="." mode="copy"/>
      </xsl:when>
    <xsl:otherwise>
      <!-- wrap the skippable element into an element that can hold an id -->
      <xsl:element name="{$output-subsentence-tag}" namespace="{$output-ns}">
	<xsl:attribute name="id">
	  <xsl:value-of select="concat('skip-', generate-id())" />
	</xsl:attribute>
	<xsl:apply-templates select="." mode="copy"/>
      </xsl:element>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
