<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns="http://www.idpf.org/2007/opf"
                xpath-default-namespace="http://www.idpf.org/2007/opf"
                exclude-result-prefixes="#all">

    <xsl:param name="compatibility-mode" required="yes"/>

    <xsl:template match="meta[@name]">
        <xsl:if test="not(../meta[@property=current()/@name])">
            <meta property="{@name}">
                <xsl:sequence select="@scheme"/>
                <xsl:value-of select="@content"/>
            </meta>
        </xsl:if>
        <xsl:if test="$compatibility-mode='true'">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="meta[@property]">
        <xsl:if test="../meta[@name=current()/@property]">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
