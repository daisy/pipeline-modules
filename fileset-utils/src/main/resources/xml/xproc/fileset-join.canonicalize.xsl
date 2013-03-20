<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns:d="http://www.daisy.org/ns/pipeline/data">
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    <xsl:param name="base" select="''"/>
    <xsl:variable name="xml-base" select="replace(pf:normalize-uri(if (not(/*/@xml:base)) then $base else base-uri(/*)),'[^/]+$','')"/>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="@xml:base">
                <xsl:attribute name="xml:base" select="$xml-base"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="/*/@xml:base">
                <xsl:variable name="href" select="pf:relativize-uri(pf:normalize-uri(@href),$xml-base)"/>
                <xsl:if test="not(@xml:base)">
                    <xsl:attribute name="xml:base" select="resolve-uri($href,$xml-base)"/>
                    <xsl:attribute name="d:base-added" select="'true'"/>
                </xsl:if>
                <xsl:attribute name="href" select="$href"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
