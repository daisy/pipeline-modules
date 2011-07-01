<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:mo="http://www.w3.org/ns/SMIL" exclude-result-prefixes="#all" version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="iteration-position" required="yes"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mo:body">
        <xsl:call-template name="add-id">
            <xsl:with-param name="id" select="concat('mo',$iteration-position)"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="add-id">
        <xsl:param name="id" required="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="id" select="$id"/>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::*">
                        <xsl:variable name="new-id"
                            select="concat($id,
                                                                if (self::mo:seq)
                                                                    then (
                                                                        if (ancestor::mo:seq) then '-' else '_seq'
                                                                    ) else
                                                                        concat('_',local-name()),
                                                if (self::mo:text or self::mo:audio) then '' else (count(preceding-sibling::*)+1))"/>
                        <xsl:call-template name="add-id">
                            <xsl:with-param name="id" select="$new-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
