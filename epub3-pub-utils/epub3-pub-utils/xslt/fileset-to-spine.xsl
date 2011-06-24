<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.idpf.org/2007/opf"
    xpath-default-namespace="http://www.idpf.org/2007/opf"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    version="2.0" exclude-result-prefixes="#all">
    
    <!--Receives a document in the form:
    <wrapper>
        <d:fileset>
            <d:file>*
        </d:fileset>
        <opf:manifest>
            <opf:item>*
        </opf:manifest>
    </wrapper>-->

    <xsl:template match="d:fileset">
        <spine>
            <xsl:apply-templates select="d:file[@href]"/>
        </spine>
    </xsl:template>
    
    <xsl:template match="d:file">
        <xsl:variable name="href" select="@href"/>
        <itemref idref="{//item[@href=$href]/@id}"/>
    </xsl:template>

</xsl:stylesheet>
