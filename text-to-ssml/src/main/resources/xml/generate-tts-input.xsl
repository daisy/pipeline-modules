<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    exclude-result-prefixes="#all"
    version="2.0">


  <!--======================================================================= -->
  <!-- Create a SSML file for every future TTS thread. The SSML files will -->
  <!-- contain a list of SSML sentences. Each one carries the CSS -->
  <!-- properties inherited from their parents. The CSS cues and pauses are -->
  <!-- all handled by this script, including the ones inside the -->
  <!-- sentences. Aside from the pauses and the cues, the sentences' -->
  <!-- content is left unchanged. -->
  <!-- For now, cues' location are relative to the CSS sheet location. -->
  <!--======================================================================= -->

  <xsl:param name="css-sheet-uri"/>
  <xsl:variable name="css-sheet-dir" select="substring-before($css-sheet-uri, tokenize($css-sheet-uri, '/')[last()])"/>

  <xsl:variable name="tmp-ns" select="'http://www.daisy.org/ns/pipeline/tmp'"/>

  <xsl:template match="/">
    <tmp:root>
      <xsl:for-each-group select="//ssml:s" group-adjacent="@thread-id">
	<ssml:speak>
	  <xsl:for-each select="current-group()">

	    <ssml:s>

	      <!-- pauses and cues before -->
	      <xsl:choose>
		<xsl:when test="not(current()/preceding-sibling::*[1])">
		  <xsl:apply-templates select="current()/parent" mode="prev"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:apply-templates select="current()/preceding::*[1]" mode="prev"/>
		</xsl:otherwise>
	      </xsl:choose>

	      <!-- Project the parents' CSS properties on the sentence -->
	      <xsl:copy-of select="@*"/>
	      <xsl:apply-templates select="current()" mode="project-css-properties">
		<xsl:with-param name="properties" select="'voice-family,richness,volume,rate,stress,speech-rate,pitch,pitch-range,speak,azimuth,speak-punctuation,speak-numeral,elevation'"/>
	      </xsl:apply-templates>
	      <xsl:attribute namespace="http://www.w3.org/XML/1998/namespace" name="lang">
		<xsl:value-of select="current()/ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
	      </xsl:attribute>

	      <!-- sentence content -->
	      <xsl:apply-templates select="current()/node()" mode="inside-sentence"/>
	      <ssml:break time="250ms"/>

	      <!-- pauses and cues after -->
	      <xsl:apply-templates select="current()/*[1]" mode="next"/>

	    </ssml:s>
	  </xsl:for-each>
	</ssml:speak>
      </xsl:for-each-group>
    </tmp:root>
  </xsl:template>

  <!-- === iterate over the previous elements in inverse tree-order === -->
  <xsl:template match="ssml:s" mode="prev">
  </xsl:template>
  <xsl:template match="*" mode="prev">
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::*[1])">
	<xsl:apply-templates select="parent" mode="prev"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="preceding::*[1]" mode="prev"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@tmp:pause-before" mode="pause"/>
    <xsl:apply-templates select="@tmp:cue-before" mode="cue"/>
  </xsl:template>

  <!-- === iterate over the next elements in tree-order === -->
  <xsl:template match="ssml:s" mode="next">
  </xsl:template>
  <xsl:template match="*" mode="next">
    <xsl:choose>
      <xsl:when test="*[1]">
	<xsl:apply-templates select="*[1]" mode="next"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="following::*[1]" mode="next"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@tmp:cue-after" mode="cue"/>
    <xsl:apply-templates select="@tmp:pause-after" mode="pause"/>
  </xsl:template>

  <!-- === copy the sentences' content and add the break and pauses if necessary === -->
  <xsl:template match="*" mode="inside-sentence">
    <xsl:apply-templates select="@tmp:pause-before" mode="pause"/>
    <xsl:apply-templates select="@tmp:cue-before" mode="cue"/>

    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="inside-sentence"/>
    </xsl:element>

    <xsl:apply-templates select="@tmp:cue-after" mode="cue"/>
    <xsl:apply-templates select="@tmp:pause-after" mode="pause"/>
  </xsl:template>
  <xsl:template match="text()" mode="inside-sentence">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="@*" mode="pause">
    <ssml:break time="{.}"/>
  </xsl:template>

  <xsl:template match="@*" mode="cue">
    <xsl:variable name="abs-uri" select="resolve-uri(., $css-sheet-dir)"/>
    <xsl:if test="starts-with($abs-uri, 'file:/')">
      <xsl:choose>
    	<xsl:when test="starts-with($abs-uri, 'file:///')">
    	  <ssml:audio src="{substring-after($abs-uri, 'file://')}"/>
    	</xsl:when>
    	<xsl:otherwise>
    	  <ssml:audio src="{substring-after($abs-uri, 'file:')}"/>
    	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="project-css-properties">
    <xsl:param name="properties"/>
    <xsl:if test="$properties != ''">
      <xsl:variable name="property" select="substring-before($properties, ',')"/>
      <xsl:variable name="ref" select="ancestor-or-self::*[@*[local-name() = $property and namespace-uri() = $tmp-ns]][1]"/>
      <xsl:if test="$ref">
	<xsl:attribute namespace="{$tmp-ns}" name="{$property}">
	  <xsl:value-of select="$ref/@*[local-name() = $property and namespace-uri() = $tmp-ns]" />
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="." mode="project-css-properties">
	<xsl:with-param name="properties" select="substring-after($properties, ',')"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

