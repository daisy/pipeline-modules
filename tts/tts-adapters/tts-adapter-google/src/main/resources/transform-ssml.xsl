<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:s="http://www.w3.org/2001/10/synthesis"
                xmlns="http://www.w3.org/2001/10/synthesis"
                xpath-default-namespace="http://www.w3.org/2001/10/synthesis"
                exclude-result-prefixes="#all">

  <xsl:output omit-xml-declaration="yes"/>

  <xsl:template match="*">
    <speak version="1.0">
      <xsl:apply-templates mode="copy" select="if (local-name()='speak') then node() else ."/>
      <break time="250ms"/>
    </speak>
  </xsl:template>

  <xsl:template mode="copy" match="@xml:lang">
    <!-- not copied in order to prevent inconsistency with the current voice -->
  </xsl:template>

  <xsl:template mode="copy" match="token">
    <!-- tokens are not copied because they are not SSML1.0-compliant and not SAPI-compliant -->
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="copy" match="s:*">
    <xsl:element name="{local-name(.)}" namespace="{namespace-uri(.)}">
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="copy" match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
