<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method='xml' indent='yes'/>
    <xsl:strip-space elements='*'/>
    <xsl:template match="*">
        <xsl:copy copy-namespaces="no">
            <xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'"/>
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>