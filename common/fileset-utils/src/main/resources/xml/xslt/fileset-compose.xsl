<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

    <xsl:variable name="a" as="element(d:fileset)">
        <xsl:apply-templates mode="normalize" select="collection()[1]/*">
            <xsl:with-param name="base" tunnel="yes" select="collection()[1]/*/base-uri(.)"/>
        </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="b" as="element(d:fileset)">
        <xsl:apply-templates mode="normalize" select="collection()[2]/*">
            <xsl:with-param name="base" tunnel="yes" select="collection()[2]/*/base-uri(.)"/>
        </xsl:apply-templates>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:for-each select="$a">
            <xsl:copy>
                <xsl:apply-templates select="@* except @xml:base"/>
                <xsl:variable name="files" as="element(d:file)*">
                    <xsl:apply-templates select="d:file"/>
                    <xsl:sequence select="$b/d:file[not(@original-href=$a/d:file/(@href,@original-href))]"/>
                </xsl:variable>
                <xsl:variable name="base" as="xs:string?" select="($b/@xml:base,@xml:base)[1]"/>
                <xsl:choose>
                    <xsl:when test="exists($base)">
                        <xsl:attribute name="xml:base" select="$base"/>
                        <xsl:apply-templates mode="relativize" select="$files">
                            <xsl:with-param name="base" tunnel="yes" select="$base"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$files"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="d:file/@href">
        <xsl:variable name="file" as="xs:string" select="."/>
        <xsl:variable name="new-file" as="xs:string?" select="$b/d:file[@original-href=$file][1]/@href"/>
        <xsl:choose>
            <xsl:when test="exists($new-file)">
                <xsl:attribute name="{name(.)}" select="$new-file"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="normalize"
                  match="d:fileset/@xml:base|
                         d:file/@href|
                         d:file/@original-href">
        <xsl:param name="base" tunnel="yes" required="yes"/>
        <xsl:attribute name="{name()}" select="pf:normalize-uri(resolve-uri(.,$base))"/>
    </xsl:template>

    <xsl:template mode="relativize" match="d:file/@href">
        <xsl:param name="base" tunnel="yes" required="yes"/>
        <xsl:attribute name="href" select="pf:relativize-uri(.,$base)"/>
    </xsl:template>

    <xsl:template mode="#default normalize relativize" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
