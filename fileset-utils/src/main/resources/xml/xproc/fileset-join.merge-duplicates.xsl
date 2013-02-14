<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:d="http://www.daisy.org/ns/pipeline/data">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:variable name="href" select="@href"/>
        <xsl:if test="not(preceding::d:file/@href=$href)">
            <xsl:copy>
                <xsl:apply-templates select="@* | following::d:file[@href=$href]/@*"/>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
