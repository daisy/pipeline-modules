<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="output-ns" />
  <xsl:param name="skippable-tags" />
  <xsl:param name="output-subsentence-tag" />
  <xsl:param name="can-contain-subsentences" />
  <xsl:param name="id-prefix" />

  <xsl:key name="sentences" match="*[@id]" use="@id"/>

  <!-- - - - - - - -->
  <!-- Look for the sentences. Either split them or copy them. -->

  <xsl:variable name="skippable-tag-list" select="concat(',', $skippable-tags, ',')" />

  <xsl:template match="@*|node()" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[key('sentences', @id, collection()[/d:sentences])]" priority="2">
    <xsl:choose>
      <xsl:when test="count(descendant::*[contains($skippable-tag-list, concat(',', local-name(), ','))]) = 0">
	<xsl:apply-templates select="." mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="." mode="split"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - -->
  <!-- Copy the sentences. -->

  <xsl:template match="node()" mode="copy" priority="1">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="*" mode="copy" priority="2">
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="copy"/>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - -->
  <!-- Split the sentences. -->

  <xsl:template match="node()" mode="split" priority="1">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="split"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="ok-parent-list" select="concat(',', $can-contain-subsentences, ',')" />
  <xsl:template match="*[contains($ok-parent-list, concat(',', local-name(), ','))]"
		mode="split" priority="2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- Group together the adjacent nodes that do not contain any skippable elements. -->
      <!-- When they do, we recursively call the split mode. -->
      <xsl:for-each-group select="node()"
			  group-adjacent="not(descendant-or-self::*[contains($skippable-tag-list, concat(',', local-name(), ','))][1])">
	<xsl:choose>
	  <xsl:when test="not(current-grouping-key())">
	    <xsl:apply-templates select="current-group()" mode="split"/>
	  </xsl:when>
	  <!-- An existing node (holding an @id) is recycled -->
	  <xsl:when test="count(current-group()) = 1 and current-group()[1]/@id">
	    <xsl:apply-templates select="current-group()" mode="copy"/>
	  </xsl:when>
	  <!-- Silent fragment. -->
	  <xsl:when test="matches(string-join(current-group()/descendant-or-self::text(),''),'^[\p{M}\p{P}\p{Z}\t\r\n]*$')">
	    <xsl:apply-templates select="current-group()" mode="copy"/>
	  </xsl:when>
	  <!-- An existing node (not holding an @id) is recycled  -->
	  <xsl:when test="count(current-group()) = 1 and local-name(current-group()[1]) = $output-subsentence-tag">
	    <xsl:copy>
	      <xsl:copy-of select="@*"/>
	      <xsl:apply-templates select="current-group()[1]" mode="add-id">
		<xsl:with-param name="prefix" select="'sub'"/>
	      </xsl:apply-templates>
	      <xsl:apply-templates select="current-group()/node()" mode="copy"/>
	    </xsl:copy>
	  </xsl:when>
	  <!-- General case. -->
	  <xsl:otherwise>
	    <xsl:element name="{$output-subsentence-tag}" namespace="{$output-ns}">
	      <xsl:apply-templates select="current-group()[1]" mode="add-id">
		<xsl:with-param name="prefix" select="'sub'"/>
	      </xsl:apply-templates>
	      <xsl:apply-templates select="current-group()" mode="copy"/>
	    </xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[contains($skippable-tag-list, concat(',', local-name(), ','))]"
		mode="split" priority="3">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="not(@id)">
	<xsl:apply-templates select="." mode="add-id">
	  <xsl:with-param name="prefix" select="'skip'"/>
	</xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="add-id">
    <xsl:param name="prefix"/>
    <xsl:attribute name="id">
      <xsl:value-of select="concat($prefix, '-', $id-prefix, generate-id(.))" />
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
