<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

    <xsl:param name="output-base-uri" required="yes"/>

    <xsl:variable name="mapping" as="element()">
        <xsl:apply-templates mode="absolute-hrefs" select="collection()[2]"/>
    </xsl:variable>

    <xsl:template mode="absolute-hrefs"
                  match="d:file/@href|
                         d:file/@original-href">
        <xsl:attribute name="{name()}" select="resolve-uri(.,base-uri(.))"/>
    </xsl:template>

    <xsl:template match="/d:audio-clips">
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="d:clip/@src">
        <xsl:variable name="src" select="resolve-uri(.,pf:base-uri(.))"/>
        <xsl:variable name="file" as="element()?" select="$mapping[@original-href=$src]"/>
        <xsl:variable name="src" select="($file/@href,$src)[1]"/>
        <xsl:attribute name="src" select="pf:relativize-uri($src,$output-base-uri)"/>
    </xsl:template>

    <xsl:template mode="#default absolute-hrefs" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
