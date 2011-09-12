<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="nav-doc-uri" required="yes"/>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="*">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="href" select="resolve-uri(@href,parent::*/@xml:base)"/>
                    <xsl:attribute name="id" select="concat('item_',count(preceding-sibling::*)+1)"/>
                    <xsl:if test="resolve-uri(@href,/*/@xml:base)=$nav-doc-uri">
                        <xsl:attribute name="properties" select="'nav'"/>
                    </xsl:if>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
