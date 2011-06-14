<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.idpf.org/2007/opf"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    version="2.0" exclude-result-prefixes="#all">

    <xsl:template match="d:fileset">
        <manifest>
            <xsl:apply-templates select="d:file[@href]"/>
        </manifest>
    </xsl:template>
    
    <xsl:template match="d:file">
        <item href="{@href}" id="{if (@id) then @id else generate-id()}" media-type="{@media-type}"/>
    </xsl:template>

</xsl:stylesheet>
