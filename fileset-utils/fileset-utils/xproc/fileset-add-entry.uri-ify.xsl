<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" version="2.0">
    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    <xsl:param name="to" required="yes"/>
    <xsl:param name="from" required="yes"/>
    <xsl:template match="/*">
        <d:file>
            <xsl:attribute name="href" select="pf:file-resolve-relative-uri($to,$from)"/>
        </d:file>
    </xsl:template>
</xsl:stylesheet>
