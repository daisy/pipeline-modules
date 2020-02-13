<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>
    <xsl:import href="http://www.daisy.org/pipeline/modules/html-utils/library.xsl"/>

    <!--
        A fileset defines the relocation of resources.
    -->
    <xsl:variable name="mapping" as="element(d:fileset)">
        <xsl:apply-templates mode="normalize" select="collection()[/d:fileset][1]"/>
    </xsl:variable>

    <xsl:variable name="doc-base" select="pf:html-base-uri(/)"/>
    <xsl:variable name="original-doc-base"
                  select="(for $file in $mapping/d:file[resolve-uri(@href,base-uri(.))=base-uri(current())][1] return
                           pf:html-base-uri(/,$file/@original-href),
                           $doc-base)[1]"/>

    <xsl:template match="@aria-describedat  |
                         @longdesc          |
                         link/@href         |
                         a/@href            |
                         area/@href         |
                         script/@scr        |
                         img/@src           |
                         iframe/@src        |
                         embed/@src         |
                         object/@data       |
                         audio/@src         |
                         video/@src         |
                         source/@src        |
                         track/@src         |
                         input/@src         |
                         input/@formaction  |
                         button/@formaction |
                         form/@action       |
                         blockquote/@cite   |
                         q/@cite            |
                         ins/@cite          |
                         del/@cite          |
                         head/@profile      |
                         svg:*/@xlink:href  |
                         svg:*/@href        |
                         m:math/@altimg     |
                         m:mglyph/@src      ">
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

    <xsl:template mode="normalize"
                  match="d:file/@href|
                         d:file/@original-href">
        <xsl:attribute name="{name()}" select="pf:normalize-uri(resolve-uri(.,base-uri(..)))"/>
    </xsl:template>

    <xsl:template mode="#default normalize" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
