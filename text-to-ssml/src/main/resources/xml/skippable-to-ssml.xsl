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

  <xsl:variable name="reshaped-skippable-elements" select="concat(',', $skippable-elements, ',')" />

  <xsl:template match="/">
    <xsl:copy>
      <xsl:element name="{name(/*)}" namespace="{namespace-uri(/*)}">
	<xsl:copy-of select="/*/@*"/>
	<xsl:apply-templates select="/*/node()"/>

	<!-- The skippable types are processed one-by-one to prevent any prosody problems -->
	<xsl:call-template name="one-skippable">
	  <xsl:with-param name="skippable-list" select="$skippable-elements"/>
	</xsl:call-template>

      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="one-skippable">
    <xsl:param name="skippable-list"/>
    <xsl:variable name="skippable" select="substring-before($skippable-list, ',')"/>
    <xsl:if test="$skippable != ''">
      <xsl:variable name="all-skippable" select="//*[local-name() = $skippable]"/>
      <xsl:if test="$all-skippable">
	<tmp:group> <!-- Makes possible to the Java-step to process the following sentence in a separate thread. -->
	  <!-- Adding a non-existing element here allows us to apply
	       CSS properties on the whole sentence, especially the
	       engine name which is customizable at the sentence-level
	       only. -->
	  <xsl:element name="{$skippable}" namespace="http://www.daisy.org/ns/pipeline/tmp">
	    <!-- The id does not matter here because it won't be visible in the output document. -->
	    <!-- Only the ssml:marks' id will be visible. -->
	    <ssml:s id="{concat('group-of-', $skippable)}">
	      <xsl:for-each select="$all-skippable">
		<xsl:variable name="id" select="if (current()/@id) then (current()/@id) else (current()/../@id)"/>
		<xsl:if test="$id">
		  <ssml:mark name="{concat($mark-delimiter, $id)}"/>
		  <xsl:copy-of select="current()"/>
		  <ssml:mark name="{concat($id, $mark-delimiter)}"/>
		  <xsl:value-of select="' , '"/> <!-- break in prosody -->
		</xsl:if>
	      </xsl:for-each>
	    </ssml:s>
	  </xsl:element>
	</tmp:group>
      </xsl:if>
      <xsl:call-template name="one-skippable">
	<xsl:with-param name="skippable-list" select="substring-after($skippable-list, ',')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|node()" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@id and ((count(*|text()) = 1
		       and contains($reshaped-skippable-elements, concat(',', *[1]/local-name(), ',')))
		       or contains($reshaped-skippable-elements, concat(',', local-name(), ',')))]"
		priority="2">

    <ssml:mark name="{concat(preceding-sibling::*[@id][1]/@id, $mark-delimiter, following-sibling::*[@id][1]/@id)}"/>
  </xsl:template>

</xsl:stylesheet>

