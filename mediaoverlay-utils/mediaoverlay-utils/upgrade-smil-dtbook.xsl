<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:s="http://www.w3.org/2001/SMIL20/"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions" exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:include href="clock-functions.xsl"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/*">
        <smil xmlns="http://www.w3.org/ns/SMIL"
            profile="http://www.idpf.org/epub/30/profile/content/" version="3.0">
            <xsl:apply-templates select="@id|*"/>
        </smil>
    </xsl:template>
    <xsl:template match="s:head"/>
    <xsl:template match="s:body">
        <body xmlns="http://www.w3.org/ns/SMIL">
            <xsl:call-template name="seq">
                <xsl:with-param name="body" select="true()"/>
            </xsl:call-template>
        </body>
    </xsl:template>
    <xsl:template match="s:seq" name="seq">
        <xsl:param name="body" select="false()"/>
        <xsl:variable name="children" select="s:seq | s:par | s:text | s:audio"/>
        <xsl:for-each-group select="$children" group-adjacent="self::s:seq or self::s:par">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:for-each select="current-group()">
                        <xsl:choose>
                            <xsl:when test="self::s:par">
                                <xsl:if test="descendant::s:text[parent::*/descendant::s:audio]">
                                    <xsl:apply-templates select="."/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="$body and count(current-group())=1">
                                <xsl:apply-templates select="."/>
                            </xsl:when>
                            <xsl:when
                                test="count(descendant::s:text[parent::*/descendant::s:audio]) &gt; 1">
                                <seq xmlns="http://www.w3.org/ns/SMIL">
                                    <xsl:apply-templates select="@id"/>
                                    <xsl:apply-templates select="."/>
                                </seq>
                            </xsl:when>
                            <xsl:when test="descendant::s:text[parent::*/descendant::s:audio]">
                                <xsl:apply-templates select="."/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if
                        test="current-group()/descendant-or-self::s:audio and current-group()/descendant-or-self::s:text">
                        <xsl:call-template name="par">
                            <xsl:with-param name="children" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    <xsl:template match="s:par" name="par">
        <xsl:param name="children" select="*"/>
        <par xmlns="http://www.w3.org/ns/SMIL">
            <xsl:apply-templates select="@id"/>
            <text xmlns="http://www.w3.org/ns/SMIL">
                <xsl:apply-templates
                    select="$children[self::s:text][1]/@src | $children[self::s:text][1]/@id"/>
            </text>
            <xsl:variable name="audio" select="$children/descendant-or-self::s:audio"/>
            <xsl:if test="$audio">
                <audio xmlns="http://www.w3.org/ns/SMIL" src="{$audio[1]/@src}">
                    <xsl:apply-templates select="$audio[1]/@id"/>
                    <xsl:variable name="clipBegin"
                        select="pf:mediaoverlay-clock-value-to-seconds($audio[1]/@clipBegin)"/>
                    <xsl:variable name="clipEnd"
                        select="pf:mediaoverlay-clock-value-to-seconds($audio[@src=$audio[1]/@src][last()]/@clipEnd)"/>
                    <xsl:attribute name="clipBegin"
                        select="if ($clipBegin &lt; 60) then pf:mediaoverlay-seconds-to-timecount($clipBegin)
                                else if ($clipBegin &lt; 3600) then pf:mediaoverlay-seconds-to-partial-clock-value($clipBegin)
                                else pf:mediaoverlay-seconds-to-full-clock-value($clipBegin)"/>
                    <xsl:attribute name="clipEnd"
                        select="if ($clipEnd &lt; 60) then pf:mediaoverlay-seconds-to-timecount($clipEnd)
                                else if ($clipEnd &lt; 3600) then pf:mediaoverlay-seconds-to-partial-clock-value($clipEnd)
                                else pf:mediaoverlay-seconds-to-full-clock-value($clipEnd)"
                    />
                </audio>
            </xsl:if>
        </par>
    </xsl:template>
</xsl:stylesheet>
