<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
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
    <xsl:apply-templates select="." mode="create-sentence"/>
  </xsl:template>

  <!-- Keep the sentence where it is, if possible. Otherwise split it. -->

  <xsl:variable name="ok-parent-list" select="concat(',', $can-contain-sentences, ',')"/>
  <xsl:template match="*[contains($ok-parent-list, concat(',', local-name(..), ','))]"
		mode="create-sentence" priority="3">
    <xsl:element name="{$tmp-sentence-tag}" namespace="{$tmp-ns}">
      <xsl:copy-of select="node()"/> <!-- including the <tmp:word> nodes. -->
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-word-tag]" mode="create-sentence" priority="2">
    <xsl:copy-of select="node()"/> <!-- ignore the tmp:word -->
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" mode="create-sentence" priority="2">
    <!-- Inserting sentences is forbidden here. -->
    <xsl:apply-templates select="node()" mode="create-sentence"/>
  </xsl:template>

  <xsl:template match="node()" mode="create-sentence" priority="1">
    <!-- Inserting sentences is forbidden here. -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="create-sentence"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

