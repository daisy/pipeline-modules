<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.idpf.org/2007/opf" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:output indent="yes"/>
    
    <xsl:template match="d:fileset">
        <manifest>
            <xsl:apply-templates select="d:file"/>
        </manifest>
    </xsl:template>
    
    <xsl:template match="d:file">
        <item href="{@href}" media-type="{@media-type}" id="{concat('item_',position())}">
            <xsl:if
                test="@media-type='application/xhtml+xml' and not(tokenize(@href,'/')[last()]='navigation.xhtml')">
                <xsl:variable name="smil" select="replace(@href,'xhtml$','smil')"/>
                <xsl:attribute name="media-overlay"
                    select="concat('item_',count((//d:file[@href=$smil]/preceding-sibling::d:file))+1)"
                />
            </xsl:if>
        </item>
        <!-- NOTE: this assumes that the media overlays were generated based on the content documents
            (i.e. they have the same names and are located in the same directories;
            ([./doc.xhtml,./doc.smil], [./Content/frontmatter.xhtml,./Content/frontmatter.smil] etc.) -->
    </xsl:template>

</xsl:stylesheet>
