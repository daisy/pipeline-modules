<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions" xmlns:d="http://www.daisy.org/ns/pipeline/data" version="2.0">
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="xml-base" select="f:resolve-dot-segments(resolve-uri(replace(replace(/*/@xml:base,'^(\w:)','file:/$1'),'\\','/')))"/>
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
            <xsl:attribute name="href" select="f:resolve-dot-segments(resolve-uri(replace(replace(@href,'^(\w:)','file:/$1'),'\\','/'),$xml-base))"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="xml-base" select="$xml-base" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="f:resolve-dot-segments">
        <xsl:param name="uri"/>
        <xsl:value-of
            select="if (matches($uri,'/([^:/\.][^:/]*|\.[^:/\.][^:/]*|\.\.[^:/]+)/\.\./'))
                        then f:resolve-dot-segments(replace($uri,'^(.*?)/([^:/\.][^:/]*|\.[^:/]+)/\.\./(.*)$','$1/$3'))
                        else if (matches($uri,'/\./'))
                            then f:resolve-dot-segments(replace($uri,'/\./','/'))
                            else $uri"
        />
    </xsl:function>
</xsl:stylesheet>
