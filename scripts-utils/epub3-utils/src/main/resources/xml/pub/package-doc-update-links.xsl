<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns="http://www.idpf.org/2007/opf"
                xpath-default-namespace="http://www.idpf.org/2007/opf"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

    <!--
        A fileset defines the relocation of resources.
        We know that it has been previously normalized.
    -->
    <xsl:variable name="mapping" as="element(d:fileset)">
        <xsl:apply-templates mode="absolute-hrefs" select="collection()[/d:fileset][1]"/>
    </xsl:variable>

    <xsl:variable name="original-doc-base" select="base-uri(/)"/>
    <xsl:variable name="doc-base"
                  select="($mapping/d:file[resolve-uri(@original-href,base-uri(.))=$original-doc-base][1]/@href,
                           $original-doc-base)[1]"/>

    <xsl:template match="link/@href    |
                         item/@href    ">
        <xsl:variable name="uri" as="xs:string" select="pf:normalize-uri(.)"/>
        <xsl:variable name="uri" as="xs:string*" select="pf:tokenize-uri($uri)"/>
        <xsl:variable name="fragment" as="xs:string?" select="$uri[5]"/>
        <xsl:variable name="file" as="xs:string" select="pf:recompose-uri($uri[position()&lt;5])"/>
        <xsl:variable name="resolved-file" as="xs:anyURI" select="resolve-uri($file,$original-doc-base)"/>
        <xsl:variable name="new-file" as="xs:string?" select="$mapping/d:file[@original-href=$resolved-file][1]/@href"/>
        <xsl:choose>
            <xsl:when test="exists($new-file)">
                <xsl:variable name="new-uri" select="string-join(($new-file,$fragment),'#')"/>
                <xsl:attribute name="{name(.)}" select="pf:relativize-uri($new-uri,$doc-base)"/>
            </xsl:when>
            <xsl:when test="$doc-base!=$original-doc-base and pf:is-relative(.)">
                <xsl:variable name="new-uri" select="string-join(($resolved-file,$fragment),'#')"/>
                <xsl:attribute name="{name(.)}" select="pf:relativize-uri($new-uri,$doc-base)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="absolute-hrefs"
                  match="d:file/@href|
                         d:file/@original-href">
        <xsl:attribute name="{name()}" select="resolve-uri(.,base-uri(..))"/>
    </xsl:template>

    <xsl:template mode="#default absolute-hrefs" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
