<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data">
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="xml-base" select="replace(pf:file-uri-ify(base-uri(/*)),'[^/]+$','')"/>
            <xsl:attribute name="xml:base" select="$xml-base"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="xml-base" select="$xml-base" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:param name="xml-base" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="href" select="resolve-uri(pf:file-uri-ify(@href),$xml-base)"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
