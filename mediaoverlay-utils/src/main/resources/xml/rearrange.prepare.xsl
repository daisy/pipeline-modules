<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:di="http://www.daisy.org/ns/pipeline/tmp" xmlns:mo="http://www.w3.org/ns/SMIL" version="2.0" exclude-result-prefixes="#all">
    <xsl:template match="/di:smil-map">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="document" select="/"/>
            <xsl:for-each select="distinct-values(//mo:text/@src)">
                <xsl:variable name="src" select="."/>
                <content xmlns="http://www.daisy.org/ns/pipeline/tmp" src="{$src}">
                    <xsl:for-each select="$document//mo:text[@src=$src]">
                        <xsl:variable name="base" select="@xml:base"/>
                        <text xmlns="http://www.daisy.org/ns/pipeline/tmp" smil-id="{@id}" src-fragment="{@fragment}" xml:base="{$base}">
                            <xsl:for-each select="../mo:audio">
                                <audio xmlns="http://www.w3.org/ns/SMIL" src="{resolve-uri(@src,$base)}" id="{@id}" clipBegin="{@clipBegin}" clipEnd="{@clipEnd}"/>
                            </xsl:for-each>
                        </text>
                    </xsl:for-each>
                </content>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>