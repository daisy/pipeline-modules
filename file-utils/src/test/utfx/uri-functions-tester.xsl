<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:import href="../../main/resources/xml/xslt/uri-functions.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:template match="* | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="test[@function='relativize']">
        <xsl:variable name="result" select="pf:relativize-uri(@uri,@base)"/>
        <xsl:if test="$result ne @expected">
            <error>
                <xsl:copy-of select="@*"/>
                <xsl:value-of select="$result"/>
            </error>
        </xsl:if>
    </xsl:template>
    <xsl:template match="test[@function='normalize']">
        <xsl:variable name="result" select="pf:normalize-uri(@uri)"/>
        <xsl:if test="$result ne @expected">
            <error>
                <xsl:copy-of select="@*"/>
                <xsl:value-of select="$result"/>
            </error>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>