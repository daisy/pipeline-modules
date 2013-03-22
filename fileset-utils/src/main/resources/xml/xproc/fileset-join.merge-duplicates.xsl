<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:d="http://www.daisy.org/ns/pipeline/data">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:variable name="href" select="resolve-uri(@href,base-uri(.))"/>
        <xsl:if test="not(preceding::d:file/resolve-uri(@href,base-uri(.))=$href)">
            <xsl:copy>
                <xsl:apply-templates select="@* | following::d:file[resolve-uri(@href,base-uri(.))=$href]/@*"/>
                <xsl:apply-templates select="node() | following::d:file[resolve-uri(@href,base-uri(.))=$href]/node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
