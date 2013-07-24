<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    exclude-result-prefixes="xs"
    version="2.0">
  
  <xsl:template match="node()">
    <!-- include both the attribute names and values in the grouping key -->
    <xsl:for-each-group select=".|following-sibling::node()" group-adjacent="concat(local-name(), string-join(@*, '_'), string-join(@*/name(), '_'))">
      <xsl:choose>
	<!-- group if name() belongs to the list of mergeable markups passed as parameter -->
	<xsl:when test="@tmp:mergeable">
	  <!-- copy only the first node of the group => grouping --> 
	  <xsl:copy>
	    <xsl:copy-of select="@*" />
	    <xsl:for-each select="current-group()">
	      <xsl:apply-templates select="node()[1]"/>
	    </xsl:for-each>
	  </xsl:copy>
	</xsl:when>
	
	<xsl:otherwise>
	  <!-- copy the node node every time => no grouping --> 
	  <xsl:for-each select="current-group()">
	    <xsl:copy>
	      <xsl:copy-of select="@*" />
	      <xsl:apply-templates select="node()[1]"/>
	    </xsl:copy>
	  </xsl:for-each>
	</xsl:otherwise>
	
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
</xsl:stylesheet>

