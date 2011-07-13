<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data">
    <xsl:variable name="base" select="f:longest-common-uri(distinct-values(//@xml:base/replace(.,'^(.*/)[^/]*$','$1')))"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:base" select="$base"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="d:fileset">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="d:file">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="href" select="f:relative-to(resolve-uri(@href,parent::*/@xml:base),$base)"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="f:longest-common-uri">
        <xsl:param name="uris"/>
        <xsl:choose>
            <xsl:when test="count($uris)=1">
                <xsl:value-of select="replace($uris[1],'^(.+/)[^/]*$','$1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="a" select="replace($uris[1],'/+','/')"/>
                <xsl:variable name="b" select="replace($uris[2],'/+','/')"/>
                <xsl:variable name="a-start" select="if (starts-with($uris[1],'file:')) then replace($uris[1],'^([^/]+/+)[^/].*$','$1') else replace($uris[1],'^([^/]+/+[^/]+/).*$','$1')"/>
                <xsl:variable name="b-start" select="if (starts-with($uris[2],'file:')) then replace($uris[2],'^([^/]+/+)[^/].*$','$1') else replace($uris[2],'^([^/]+/+[^/]+/).*$','$1')"/>
                <xsl:variable name="a-canonicalStart" select="replace($a-start,'/+','/')"/>
                <xsl:variable name="b-canonicalStart" select="replace($b-start,'/+','/')"/>
                <xsl:variable name="a-trail" select="substring-after(replace($a,'^(.*/)[^/]*$','$1'),$a-canonicalStart)"/>
                <xsl:variable name="b-trail" select="substring-after(replace($b,'^(.*/)[^/]*$','$1'),$b-canonicalStart)"/>
                <xsl:choose>
                    <xsl:when test="not($a-canonicalStart=$b-canonicalStart)">
                        <xsl:value-of select="f:longest-common-uri(insert-before(subsequence($uris,3),0,$uris[1]))"/>
                    </xsl:when>
                    <xsl:when test="starts-with($b-trail,$a-trail)">
                        <xsl:value-of select="f:longest-common-uri(insert-before(subsequence($uris,3),0,$uris[1]))"/>
                    </xsl:when>
                    <xsl:when test="starts-with($a-trail,$b-trail)">
                        <xsl:value-of select="f:longest-common-uri(insert-before(subsequence($uris,3),0,$uris[2]))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="a-parts" select="tokenize($a-trail,'/+')"/>
                        <xsl:variable name="b-parts" select="tokenize($b-trail,'/+')"/>
                        <xsl:variable name="longest" select="f:longest-common($a-parts,$b-parts)"/>
                        <xsl:value-of select="f:longest-common-uri(insert-before(subsequence($uris,3),0,concat($a-start,$longest)))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:longest-common">
        <xsl:param name="a"/>
        <xsl:param name="b"/>
        <xsl:choose>
            <xsl:when test="not($a[1]=$b[1])">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="count($a)=1 or count($b)=1">
                <xsl:value-of select="concat($a[1],'/')"/>
            </xsl:when>
            <xsl:when test="$a[2]=$b[2]">
                <xsl:variable name="common-base" select="concat($a[1],'/',$a[2])"/>
                <xsl:variable name="new-a" select="insert-before(subsequence($a,3),0,$common-base)"/>
                <xsl:variable name="new-b" select="insert-before(subsequence($b,3),0,$common-base)"/>
                <xsl:value-of select="f:longest-common($new-a,$new-b)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($a[1],'/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:relative-to">
        <xsl:param name="uri"/>
        <xsl:param name="base"/>
        <xsl:variable name="basedir" select="if (starts-with($base,'file:')) then replace(replace($base,'/+','/'),'^(.+/)[^/]*$','$1') else replace(replace($base,'/+','/'),'^([^/]+/[^/]+/)[^/]*$','$1')"/>
        <xsl:variable name="canonicalUri" select="replace($uri,'/+','/')"/>
        <xsl:variable name="relative" select="substring($canonicalUri,string-length($basedir)+1)"/>
        <xsl:choose>
            <xsl:when test="starts-with($canonicalUri,$basedir)">
                <xsl:value-of select="$relative"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
