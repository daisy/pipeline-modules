<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.daisy.org/ns/z3998/authoring/"
    exclude-result-prefixes="xs"
    version="2.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>    
  
  <!-- list of markups separated by ',' -->
  <xsl:param name="mergeable-markups"/>
  
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <!-- include both the attribute names and values in the grouping key -->
      <xsl:for-each-group select="node()" group-adjacent="concat(name(), string-join(@*, '_'), string-join(@*/name(), '_'))">
      	<xsl:choose>
	  <!-- group if name() belongs to the list of mergeable markups passed as parameter -->
	  <xsl:when test="contains(concat(',', $mergeable-markups, ','), concat(',', name(), ','))">
	    <!-- copy only once the first node of the group => grouping --> 
	    <xsl:copy>
	      <xsl:copy-of select="@*" />
	      <xsl:apply-templates select="current-group()/*"/>
	    </xsl:copy>
	  </xsl:when>

	<xsl:otherwise>
	  <!-- copy the node node every time => no grouping --> 
	  <xsl:apply-templates select="current-group()"/>
	</xsl:otherwise>

      </xsl:choose>
    </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>

