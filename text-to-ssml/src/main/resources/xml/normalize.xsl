<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="word-element" />
  <xsl:param name="word-attr" />
  <xsl:param name="word-attr-val" />
  <xsl:param name="section-element" />
  <xsl:param name="section-attr" />
  <xsl:param name="section-attr-val" />

  <xsl:template match="@*|node()" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" priority="1" mode="inside-sentence">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="inside-sentence"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[collection()/d:sentences/*[@id = current()/@id] and not(ancestor-or-self::ssml:s)]" priority="3">
    <ssml:s>
      <xsl:apply-templates select="@*|node()" mode="inside-sentence"/>
    </ssml:s>
  </xsl:template>

  <xsl:template match="*[local-name()=$word-element and string(@*[local-name()=$word-attr]) = $word-attr-val]" priority="2" mode="inside-sentence">
    <ssml:token>
      <xsl:apply-templates select="@*|node()" mode="inside-sentence"/>
    </ssml:token>
  </xsl:template>

  <xsl:template match="*[local-name()=$section-element and string(@*[local-name()=$section-attr]) = $section-attr-val]" priority="2">
    <tmp:group>
      <xsl:element name="{name()}" namespace="{namespace-uri()}">
	<xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </tmp:group>
  </xsl:template>

</xsl:stylesheet>

