<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data">
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:base" select="replace(pf:normalize-uri(base-uri(/*)),'[^/]+$','')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="href" select="pf:relativize-uri(pf:normalize-uri(@href),base-uri(.))"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
