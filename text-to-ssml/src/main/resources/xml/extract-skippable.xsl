<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="skippable-elements" />

  <!-- must have the same value as in the Java part -->
  <xsl:variable name="mark-delimiter" select="'___'"/>
  <xsl:variable name="skippable-list" select="concat(',', $skippable-elements, ',')" />

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates select="node()" mode="skippable-free"/>
    </xsl:copy>
    <xsl:result-document href="skippables.xml">
      <xsl:copy>
	<xsl:apply-templates select="node()" mode="skippable-only"/>
      </xsl:copy>
    </xsl:result-document>
  </xsl:template>


  <!-- === REBUILD THE DOCUMENT WITHOUT SKIPPABLE ELEMENTS -->

  <xsl:template match="@*|node()" priority="1" mode="skippable-free">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="skippable-free"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@id and contains($skippable-list, concat(',', local-name(), ','))]"
		priority="2" mode="skippable-free">
    <!-- If the skippable is not inside any sentence (i.e. the
         skippable is a sentence itself), there is no need for
         marks. But we let the empty harmless mark as it is, since it
         won't be included in any synthesizable section. -->
    <xsl:variable name="right-level" select="ancestor-or-self::*[preceding-sibling::*[@id][1] or following-sibling::*[@id][1]][1]"/>
    <!-- The skippable element is replaced with a mark delimiting
	 the end of the previous element and the beginning of the
	 next one. The skippable elements are copied in a separate
	 document. -->
    <ssml:mark name="{concat($right-level/preceding-sibling::*[@id][1]/@id, $mark-delimiter, $right-level/following-sibling::*[@id][1]/@id)}"/>
  </xsl:template>


  <!-- === REBUILD THE DOCUMENT WITH SKIPPABLE ELEMENTS ONLY -->

  <xsl:template match="@*|*" priority="1" mode="skippable-only">
    <xsl:copy>
      <xsl:apply-templates select="@*|*" mode="skippable-only"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="skippable-only">
    <!-- Ignored if not in a skippable element. -->
  </xsl:template>

  <xsl:template match="*[@id and contains($skippable-list, concat(',', local-name(), ','))]"
		priority="2" mode="skippable-only">
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>

