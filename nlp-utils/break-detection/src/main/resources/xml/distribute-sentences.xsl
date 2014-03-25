<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    exclude-result-prefixes="xs"
    version="2.0">

  <xsl:param name="tmp-ns"/>
  <xsl:param name="tmp-word-tag"/>
  <xsl:param name="tmp-sentence-tag"/>
  <xsl:param name="can-contain-sentences"/>

  <!-- Copy the document until a sentence is found. -->

  <xsl:template match="@*|node()" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" priority="2">
    <xsl:apply-templates select="." mode="create-sentence">
      <xsl:with-param name="lang" select="@xml:lang"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Keep the sentence where it is, if possible. Otherwise split it. -->

  <xsl:variable name="ok-parent-list" select="concat(',', $can-contain-sentences, ',')"/>
  <xsl:template match="node()[contains($ok-parent-list, concat(',', local-name(..), ','))]"
		mode="create-sentence" priority="3">
    <xsl:param name="lang" select="''"/>
    <xsl:choose>
      <xsl:when test="local-name() = $tmp-sentence-tag">
	<xsl:copy-of select="."/> <!-- including the <tmp:word> nodes and @xml:lang if any. -->
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="{$tmp-sentence-tag}" namespace="{$tmp-ns}">
	  <xsl:if test="$lang != ''">
	    <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
	      <xsl:value-of select="$lang"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:copy-of select="."/> <!-- including the <tmp:word> nodes. -->
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-word-tag]" mode="create-sentence" priority="2">
    <xsl:param name="lang" select="''"/>
    <xsl:copy-of select="node()"/> <!-- ignore the tmp:word -->
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" mode="create-sentence" priority="2">
    <xsl:param name="lang" select="''"/>
    <!-- Inserting sentences is forbidden here. Let's try in the children. -->
    <xsl:apply-templates select="node()" mode="create-sentence">
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="node()" mode="create-sentence" priority="1">
    <xsl:param name="lang" select="''"/>
    <!-- Inserting sentences is forbidden here. Let's try in the children -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="create-sentence">
	<xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

