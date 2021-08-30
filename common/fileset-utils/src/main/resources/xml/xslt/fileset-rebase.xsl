<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-result-prefixes="#all">
    
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>
    
    <xsl:param name="output-base-uri" required="yes"/>
    
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:base" select="$output-base-uri"/>
            <xsl:for-each select="d:file">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="not(@xml:base)">
                        <xsl:attribute name="href" select="pf:relativize-uri(resolve-uri(@href,base-uri(.)),$output-base-uri)"/>
                    </xsl:if>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
