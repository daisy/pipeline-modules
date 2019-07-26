<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:s="http://www.w3.org/ns/SMIL"
                xmlns:opf="http://www.idpf.org/2007/opf"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>

    <xsl:key name="text-refs" match="s:text/@src|@epub:textref"
             use="resolve-uri(substring-before(.,'#'),pf:base-uri(..))"/>

    <xsl:template match="opf:item[@media-type='application/xhtml+xml']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="mo"
                          select="collection()[/s:smil]
                                              [exists(key('text-refs',current()/resolve-uri(@href,base-uri(.)),.))]"/>
            <xsl:if test="exists($mo)">
                <xsl:variable name="mo-base" select="base-uri($mo/*)"/>
                <xsl:attribute name="media-overlay" select="../opf:item[resolve-uri(@href,base-uri(.))=$mo-base]/@id"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
