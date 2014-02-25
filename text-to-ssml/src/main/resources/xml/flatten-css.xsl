<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:variable name="properties"
		select="'voice-family,richness,volume,stress,speech-rate,pitch,pitch-range,speak,azimuth,speak-punctuation,speak-numeral,elevation'"/>

  <xsl:template match="*" mode="flatten-css-properties">
    <xsl:param name="style-ns" select="''"/>
    <xsl:variable name="node" select="."/>
    <xsl:for-each select="tokenize($properties, ',')">
      <xsl:variable name="property" select="current()"/>
      <xsl:variable name="ref"
		    select="$node/ancestor-or-self::*[@*[local-name() = $property and namespace-uri() = $style-ns]][1]"/>
      <xsl:if test="$ref">
	<xsl:attribute namespace="{$style-ns}" name="{$property}">
	  <xsl:value-of select="$ref/@*[local-name() = $property and namespace-uri() = $style-ns]" />
	</xsl:attribute>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

