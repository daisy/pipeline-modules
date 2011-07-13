<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.idpf.org/2007/opf" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="/*">
	<!-- TODO: The EPUB3 Navigation Document doesn't have to be named 'navigation.xhtml'. Should rather check for properties="nav" in the OPF. -->
	<!-- NOTE: This transform assumes that the input manifest is ordered according to playback order. -->
        <spine toc="{child::*[tokenize(@href,'/')[last()]='navigation.xhtml']/@id}">
            <xsl:for-each
                select="child::*[@media-type='application/xhtml+xml' and not(tokenize(@href,'/')[last()]='navigation.xhtml')]">
                <itemref idref="{@id}"/>
            </xsl:for-each>
        </spine>
    </xsl:template>

</xsl:stylesheet>
