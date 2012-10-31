<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" version="2.0" exclude-result-prefixes="#all">
    <!-- Returns a fileset of all the resources references from a DTBook (i.e. images and CSS files) -->
    <xsl:template match="/">
        <d:fileset>
            <d:file href="{base-uri(/*)}" media-type="application/x-dtbook+xml"/>
            <xsl:for-each select="processing-instruction('xml-stylesheet')">
                <d:file href="{replace(replace(.,'type=&quot;[^&quot;]*&quot;',''),'\s*href=&quot;(.*)&quot;\s*','$1')}"/>
            </xsl:for-each>
            <xsl:for-each select="//dtbook:link/@href">
                <d:file href="{.}"/>
            </xsl:for-each>
            <xsl:for-each select="//dtbook:img/@src">
                <d:file href="{.}"/>
            </xsl:for-each>
        </d:fileset>
    </xsl:template>
</xsl:stylesheet>
