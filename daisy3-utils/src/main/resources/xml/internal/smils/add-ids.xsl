<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		xmlns:dt="http://www.daisy.org/z3986/2005/dtbook/"
		exclude-result-prefixes="#all" version="2.0">

  <xsl:variable name="smil-nodes" select="' img list sent linegroup pagenum table linenum prodnote sidebar hd levelhd h1 h2 h3 h4 h5 h6 noteref annoref note annotation math '"/>

  <xsl:template match="*[not(@id) and (contains($smil-nodes, concat(' ', local-name(), ' ')) or count(dt:w) > 0)]">
    <xsl:copy>
      <xsl:attribute name="id">
	<xsl:value-of select="concat('forsmil-', generate-id())"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
