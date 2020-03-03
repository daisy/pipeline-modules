<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.daisy.org/z3986/2005/ncx/"
                exclude-result-prefixes="#all">

    <!-- FIXME: produces invalid Nav Doc when nav labels are empty   -->

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

    <xsl:param name="output-base-uri" required="yes"/>

    <xsl:variable name="ncx-uri" select="base-uri(/*)"/>
    <xsl:variable name="nav-uri" select="$output-base-uri"/>
    <xsl:variable name="htmls" select="collection()[/html:html]"/>
    <xsl:variable name="id-map" select="collection()[/d:idmap]"/>

    <xsl:key name="ids" match="*[@id]" use="@id"/>

    <xsl:template match="ncx">
        <html>
            <head>
                <title>
                    <xsl:value-of select="docTitle/text"/>
                </title>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="navMap">
        <!--ELEMENT navMap (navInfo*, navLabel*, navPoint+)-->
        <!--TODO make the default heading configurable-->
        <xsl:call-template name="nav">
            <xsl:with-param name="type" select="'toc'"/>
            <xsl:with-param name="heading" select="'Table of Contents'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="pageList">
        <!--ELEMENT pageList (navInfo*, navLabel*, pageTarget+)-->
        <!--TODO make the default heading configurable-->
        <xsl:call-template name="nav">
            <xsl:with-param name="type" select="'page-list'"/>
            <xsl:with-param name="heading" select="'List of Pages'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="navList">
        <!--ELEMENT navList (navInfo*, navLabel+, navTarget+)-->
        <!--TODO translate nav type-->
        <!--TODO what nav heading ? (required) -->
        <xsl:call-template name="nav">
            <!--<xsl:with-param name="type" select="''"/>-->
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="nav">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:param name="heading" as="xs:string?"/>
        <nav>
            <xsl:copy-of select="@id|@class"/>
            <xsl:if test="$type">
                <xsl:attribute name="epub:type" select="$type"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="navLabel/text[string(.)]">
                    <h1>
                        <xsl:apply-templates select="navLabel"/>
                    </h1>
                </xsl:when>
                <xsl:when test="$heading">
                    <h1>
                        <xsl:value-of select="$heading"/>
                    </h1>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="navInfo"/>
            <ol>
                <xsl:apply-templates select="navPoint|navTarget|pageTarget"/>
            </ol>
        </nav>
    </xsl:template>

    <xsl:template match="navPoint|navTarget|pageTarget">
        <!--ELEMENT navPoint (navLabel+, content, navPoint*)-->
        <!--ELEMENT navTarget (navLabel+, content)-->
        <!--ELEMENT pageTarget (navLabel+, content)-->
        <li>
            <xsl:copy-of select="@id|@class"/>
            <a href="{f:smil-to-html-link(content/@src)}">
                <xsl:apply-templates select="navLabel"/>
            </a>
            <xsl:if test="navPoint">
                <ol>
                    <xsl:apply-templates select="navPoint"/>
                </ol>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="navLabel">
        <!--ELEMENT navLabel (((text, audio?) | audio), img?)-->
        <!--
        We select the first navLabel that matches the NCX default language if it exists,
        or the first navLabel otherwise.
        Other navLabel elements are discarded.
        -->
        <xsl:choose>
            <xsl:when test="empty(text)">
                <xsl:message>[INFO] Discarding navLabel with no text.</xsl:message>
            </xsl:when>
            <xsl:when
                test="(@xml:lang eq /ncx/@xml:lang) 
                or (empty(preceding-sibling::navLabel) and empty(following-sibling::navLabel[@xml:lang eq /ncx/@xml:lang]))">
                <xsl:value-of select="text"/>
            </xsl:when>
            <xsl:when test="empty(text)">
                <xsl:message>[INFO] Discarding alternative navLabel "<xsl:value-of select="text"
                    />".</xsl:message>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="navInfo">
        <!--ELEMENT navInfo (((text, audio?) | audio), img?)-->
        <!--navInfo is used to present longer, explanatory or informative text regarding the structure or content of these navigation features. -->
        <xsl:message>[INFO] Discarding 'navInfo' <xsl:value-of
                select="if (string(text)) then concat('&quot;',text,'&quot;') else ''"
            /></xsl:message>
    </xsl:template>

    <xsl:template match="text()"/>

    <xsl:function name="f:smil-to-html-link" as="xs:string">
        <xsl:param name="href" as="attribute()"/>
        <xsl:variable name="smil-path" select="resolve-uri(substring-before($href,'#'),$ncx-uri)"/>
        <xsl:variable name="smil-id" select="substring-after($href,'#')"/>
        <xsl:variable name="mapping" select="$id-map/d:idmap/d:smil[@xml:base=$smil-path]/d:id[@smil-id=$smil-id]"/>
        <xsl:variable name="html-id" select="$mapping/@html-id"/>
        <xsl:variable name="html-uri" select="$htmls[key('ids',$html-id,.)][1]/base-uri(*)"/>
        <xsl:sequence select="concat(pf:relativize-uri($html-uri,$nav-uri),'#',$html-id)"/>
    </xsl:function>

</xsl:stylesheet>
