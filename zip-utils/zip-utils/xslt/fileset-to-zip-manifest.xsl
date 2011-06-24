<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    version="2.0" exclude-result-prefixes="d">

    <xsl:template match="d:fileset">
        <c:zip-manifest>
            <xsl:apply-templates select="@* | node()"/>
        </c:zip-manifest>
    </xsl:template>
    
    <xsl:template match="d:file[@href and not(matches(@href,'^[^/]+:') or starts-with(@href,'..'))]">
        <c:entry href="{@href}" name="{@href}"/>
    </xsl:template>

</xsl:stylesheet>
