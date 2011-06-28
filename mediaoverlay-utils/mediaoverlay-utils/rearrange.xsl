<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:di="http://www.daisy.org/ns/pipeline/tmp" xmlns:epub="http://www.idpf.org/2007/ops"
    xmlns:mo="http://www.w3.org/ns/SMIL" exclude-result-prefixes="#all" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <smil xmlns="http://www.w3.org/ns/SMIL"
            profile="http://www.idpf.org/epub/30/profile/content/" version="3.0">
            <body xmlns="http://www.w3.org/ns/SMIL">
                <xsl:apply-templates select="*[1]"/>
            </body>
        </smil>
    </xsl:template>

    <xsl:template match="*[not(.=/*)]">
        <xsl:variable name="name" select="name()"/>
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="src" select="@xml:base"/>
        <xsl:variable name="type" select="@epub:type"/>

        <xsl:choose>
            <xsl:when
                test="string-length($id) &gt; 0 and string-length($src) &gt; 0 and /*/*[2]/descendant::*[@fragment=$id and @src=$src]">
                <par xmlns="http://www.w3.org/ns/SMIL">
                    <text xmlns="http://www.w3.org/ns/SMIL" src="{$src}" id="{$id}">
                        <xsl:if test="string-length($type) &gt; 0">
                            <xsl:attribute name="epub:type" select="$type"/>
                        </xsl:if>
                    </text>
                    <xsl:for-each
                        select="(/*/*[2]/descendant::*[@fragment=$id and @src=$src]/parent::*/child::mo:audio)[1]">
                        <audio xmlns="http://www.w3.org/ns/SMIL" clipBegin="{@clipBegin}"
                            clipEnd="{@clipEnd}" src="{resolve-uri(@src,@xml:base)}"/>
                    </xsl:for-each>
                </par>
            </xsl:when>
            <xsl:when test="string-length($id) &gt; 0">
                <seq xmlns="http://www.w3.org/ns/SMIL" src="{$src}" fragment="{$id}">
                    <xsl:if test="string-length($type) &gt; 0">
                        <xsl:attribute name="epub:type" select="$type"/>
                    </xsl:if>
                    <xsl:apply-templates select="*"/>
                </seq>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*"/>
    </xsl:template>

</xsl:stylesheet>
