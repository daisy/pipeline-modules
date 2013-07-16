<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.daisy.org/ns/z3998/authoring/"
    exclude-result-prefixes="xs"
    version="2.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
  <xsl:param name="markup"/>

  <xsl:template match="*[local-name() = $markup]">
      <xsl:apply-templates select="." mode="inside"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- copy the children -->
  <xsl:template match="*" mode="inside">
    <xsl:choose>
      <xsl:when test="count(*) = 1 and count(text()) = 0">
	<xsl:for-each select="*">
	  <!-- just copy the current node and delegate the $markup -->
	  <!-- creation to the child -->
	  <xsl:copy>
	    <xsl:copy-of select="@*"/>
	    <!-- recursive call on the unique child -->
	    <xsl:apply-templates select="." mode = "inside"/>
	  </xsl:copy>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<!-- create the $markup because we have reached one leaf or because -->
	<!-- the current node has more than one child --> 
	<xsl:element name="{$markup}">
	  <!-- full recursive copy of all the children -->
	  <xsl:copy-of select="node()"/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

