<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:opf="http://www.idpf.org/2007/opf" version="2.0">
    
    <xsl:param name="package-uri" required="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="d:*"/>
    
    <xsl:template match="opf:item[@media-type='application/xhtml+xml']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="href" select="resolve-uri(@href,$package-uri)"/>
            <xsl:if test="//d:content/@href=$href">
                <xsl:attribute name="media-overlay" select="//opf:item[resolve-uri(@href,$package-uri) = //d:mo[d:content/@href=$href]/@href]/@id"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
