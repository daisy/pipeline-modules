<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:s="http://www.w3.org/2001/10/synthesis"
                xmlns="http://www.w3.org/2001/10/synthesis"
                xpath-default-namespace="http://www.w3.org/2001/10/synthesis"
                exclude-result-prefixes="#all">

  <xsl:output indent="no" omit-xml-declaration="yes" exclude-result-prefixes="#all"/>

  <xsl:param name="ending-mark" select="''"/>

  <xsl:template match="*">
    <speak version="1.0">
      <xsl:apply-templates mode="copy" select="if (local-name()='speak') then node() else ."/>
      <break time="250ms"/>
      <xsl:if test="$ending-mark != ''">
        <mark name="{$ending-mark}"/>
      </xsl:if>
    </speak>
  </xsl:template>

  <xsl:template mode="copy" match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="copy" match="@*">
    <xsl:attribute name="{local-name()}" select="string(.)"/>
  </xsl:template>

  <xsl:template mode="copy" match="text()">
    <xsl:copy />
  </xsl:template>

  <xsl:template mode="copy" match="@xml:lang">
    <!-- not copied in order to prevent inconsistency with the current voice -->
  </xsl:template>

  <xsl:template mode="copy" match="token">
    <!-- tokens are unwrapped because they are not SSML1.0-compliant and not SAPI-compliant-->
    <xsl:apply-templates select="node()" mode="copy"/>
    <xsl:if test="following-sibling::*">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
