<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="element"/>
  <xsl:param name="element-ns"/>
  <xsl:param name="leaf" select="''"/>

  <xsl:template match="*[local-name() = $element]">
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
      <xsl:when test="count(*) = 1 and count(text()) = 0 and (*/local-name() != $leaf)">
	<xsl:for-each select="*">
	  <!-- just copy the current node and delegate the $element -->
	  <!-- creation to the child -->
	  <xsl:copy>
	    <xsl:copy-of select="@*"/>
	    <!-- recursive call on the unique child -->
	    <xsl:apply-templates select="." mode = "inside"/>
	  </xsl:copy>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<!-- create the $element because we have reached one leaf or because -->
	<!-- the current node has more than one child --> 
	<xsl:element namespace="{$element-ns}" name="{$element}">
	  <xsl:copy-of select="node()"/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

