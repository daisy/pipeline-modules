<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:epub="http://www.idpf.org/2007/ops"
    version="2.0">
    
    <!--FIXME generate safe IDs-->
    
    <!--<xsl:attribute name="id">
        <xsl:text>id.</xsl:text>
        <xsl:number count="*" level="multiple"/>
    </xsl:attribute>-->
    
    <!--<xsl:function name="f:unique" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
        <xsl:param name="gid" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="exists($allids/id[@id=$input]">
                <xsl:sequence select="f:unique(concat($input, '_', $gid))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>-->
    
    <!--<xsl:function name="generate-new-id" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:sequence select="generate-new-id(0)"/>
    </xsl:function>
    
    <xsl:function name="generate-new-id" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="seq" as="xs:integer"/>
        <xsl:variable name="gid" select="concat(generate-id($node), '-', $seq)"/>
        <xsl:sequence select="if (exists($node/id($gid))) then 
            generate-new-id($node, $seq+1) else $gid"/>
    </xsl:function>-->
    
    <xsl:template match="body|article|aside|nav|section">
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="h1|h2|h3|h4|h5|h6|hgroup">
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="*[@epub:type='pagebreak']">
        <!--TODO FIXME: epub:type can have several values-->
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>