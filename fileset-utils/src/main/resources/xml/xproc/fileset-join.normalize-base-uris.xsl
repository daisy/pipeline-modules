<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-result-prefixes="#all">
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="/*[@xml:base] or not(matches(@href,'^\w+:'))">
                <xsl:attribute name="href" select="pf:relativize-uri(resolve-uri(@href,base-uri(.)),base-uri(/*))"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
