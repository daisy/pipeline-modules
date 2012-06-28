<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:di="http://www.daisy.org/ns/pipeline/tmp" xmlns:epub="http://www.idpf.org/2007/ops" exclude-result-prefixes="#all" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <smil xmlns="http://www.w3.org/ns/SMIL" version="3.0">
            <body xmlns="http://www.w3.org/ns/SMIL">
                <xsl:for-each select="*[1]">
                    <xsl:call-template name="make-structure"/>
                </xsl:for-each>
            </body>
        </smil>
    </xsl:template>

    <!--<di:smil-map>
        <di:content src="file:/media/500GB/minishare/minifrontpage/fp2003_frontmatter.html">
            <di:text smil-id="mo1_mo1_tx0001" src-fragment="cn0001" xml:base="file:/media/500GB/minishare/minifrontpage/s0001.smil">
                <audio src="001_microsoft_office_frontpage_2003__inside_out.mp3" id="mo1_mo1_rgn_aud_0001_0001" clipBegin="0s" clipEnd="5.399s"/>
            </di:text>
        </di:content>
    </di:smil-map>-->

    <xsl:template name="make-structure">
        <xsl:variable name="name" select="name()"/>
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="src" select="@xml:base"/>
        <xsl:variable name="type" select="@epub:type"/>

        <xsl:choose>
            <xsl:when test="$id and $src">
                <xsl:variable name="smil-element" select="(/*/*[2]/*[@src=$src]/di:text[@src-fragment=$id])[1]"/>
                <xsl:choose>
                    <xsl:when test="$smil-element/@smil-id">
                        <par xmlns="http://www.w3.org/ns/SMIL">
                            <xsl:if test="$type">
                                <xsl:attribute name="epub:type" select="$type"/>
                            </xsl:if>
                            <text xmlns="http://www.w3.org/ns/SMIL" src="{$src}#{$id}" id="{$smil-element/@smil-id}"/>
                            <xsl:copy-of select="$smil-element/*"/>
                        </par>
                    </xsl:when>
                    <xsl:otherwise>
                        <seq xmlns="http://www.w3.org/ns/SMIL" src="{$src}" fragment="{$id}">
                            <xsl:if test="string-length($type) &gt; 0">
                                <xsl:attribute name="epub:type" select="$type"/>
                            </xsl:if>
                            <xsl:for-each select="*">
                                <xsl:call-template name="make-structure"/>
                            </xsl:for-each>
                        </seq>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$id">
                <seq xmlns="http://www.w3.org/ns/SMIL" src="{$src}" fragment="{$id}">
                    <xsl:if test="string-length($type) &gt; 0">
                        <xsl:attribute name="epub:type" select="$type"/>
                    </xsl:if>
                    <xsl:for-each select="*">
                        <xsl:call-template name="make-structure"/>
                    </xsl:for-each>
                </seq>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="*">
                    <xsl:call-template name="make-structure"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
