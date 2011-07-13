<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="2.0">

    <xsl:template match="/*">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <xsl:for-each select="@*">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:call-template name="recursive"/>
        </html>
    </xsl:template>

    <xsl:template name="recursive">
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="self::text()|self::processing-instruction()|self::comment()">
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:for-each select="@*">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                        <xsl:call-template name="recursive"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
