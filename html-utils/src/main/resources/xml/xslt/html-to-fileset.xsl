<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    <!--<xsl:import href="../../../../test/xspec/mock-functions.xsl"/>-->

    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>

    <xsl:template match="text()"/>

    <xsl:variable name="doc-base"
        select="if (/html/head/base[@href][1]) then resolve-uri(normalize-space(/html/head/base[@href][1]/@href),base-uri(/*)) else base-uri(/*)"/>

    <xsl:template match="/*">
        <!--
        Builds a file set with all the resources referenced from the HTML.
        Some media types are inferred – users may have to apply additional type detection.
        -->
        <d:fileset>
            <xsl:attribute name="xml:base" select="replace($doc-base,'^(.+/)[^/]*','$1')"/>
            <xsl:apply-templates>
                <xsl:with-param name="fileset" tunnel="yes">
                    <!-- passing /html:html/d:fileset as tunneled parameter since xspec doesn't support global variables -->
                    <d:fileset>
                        <xsl:for-each select="d:fileset/d:file">
                            <xsl:if test="@original-href">
                                <d:file href="{pf:normalize-uri(string(resolve-uri(@href,base-uri(.))))}" original-href="{pf:normalize-uri(string(resolve-uri(@original-href,base-uri(.))))}"/>
                            </xsl:if>
                        </xsl:for-each>
                    </d:fileset>
                </xsl:with-param>
            </xsl:apply-templates>
        </d:fileset>
    </xsl:template>


    <xsl:template match="/processing-instruction('xml-stylesheet')">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:variable name="href" select="replace(.,'^.*href=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:variable name="type" select="replace(.,'^.*type=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:sequence
            select="f:fileset-entry($href,
            if ($type) then $type
            else if (pf:get-extension($href)='css') then 'text/css'
            else if (pf:get-extension($href)=('xsl','xslt')) then 'application/xslt+xml'
            else '',false(),$fileset)"
        />
    </xsl:template>

    <xsl:template match="link">
        <xsl:param name="fileset" tunnel="yes"/>
        <!--
            External resources: icon, prefetch, stylesheet + pronunciation
            Hyperlinks:  alternate, author, help, license, next, prev, search
        -->
        <!--Note: outbound hyperlinks that resolve outside the EPUB Container are not Publication Resources-->
        <xsl:variable name="rel" as="xs:string*" select="tokenize(@rel,'\s+')"/>
        <xsl:if test="$rel=('stylesheet','pronunciation')">
            <xsl:sequence
                select="f:fileset-entry(@href,
                if (@type) then @type
                else if (pf:get-extension(@href)='css') then 'text/css'
                else if (pf:get-extension(@href)=('xsl','xslt')) then 'application/xslt+xml'
                else if (pf:get-extension(@href)='pls') then 'application/pls+xml'
                else '',false(),$fileset)"
            />
        </xsl:if>
        <xsl:if test="$rel='stylesheet' and (@type='text/css' or pf:get-extension(@href)='css')">
            <xsl:variable name="original-href" select="f:original-href(@href, ., $fileset)"/>
            <xsl:variable name="href" select="resolve-uri(@href,base-uri(.))"/>
            <xsl:if test="unparsed-text-available($original-href)">
                <xsl:for-each
                    select="f:get-css-resources(unparsed-text($original-href),$href)">
                    <xsl:sequence select="f:fileset-entry(.,(),false(),$fileset)"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="style">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:for-each select="f:get-css-resources(.,$doc-base)">
            <xsl:sequence select="f:fileset-entry(.,(),false(),$fileset)"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="script[@src]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence
            select="f:fileset-entry(@src,if (@type) then @type else 'text/javascript',false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="a[@href]">
        <!--FIXME add out-of-spine local XHTML resources-->
    </xsl:template>


    <xsl:template match="img[@src]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:if test="not(pf:get-scheme(@src)='data')">
            <xsl:sequence
                select="f:fileset-entry(@src,
            if (matches(@src,'.*\.png$','i')) then 'image/png'
            else if (matches(@src,'.*\.jpe?g$','i')) then 'image/jpeg'
            else if (matches(@src,'.*\.gif$','i')) then 'image/gif'
            else if (matches(@src,'.*\.svg$','i')) then 'image/svg+xml'
            else (),false(),$fileset)"
            />
        </xsl:if>
    </xsl:template>

    <xsl:template match="iframe[@src]">
        <!--TODO support iframe/@srcdoc -->
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,'application/xhtml+xml',false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="embed[@src]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,@type,false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="object[@data]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence
            select="f:fileset-entry(@data,@type,f:is-audio(@data,@type) or f:is-video(@data,@type), $fileset)"
        />
    </xsl:template>


    <xsl:template match="audio[@src]|video[@src]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,(),true(),$fileset)"/>
    </xsl:template>

    <xsl:template match="source">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,@type,true(),$fileset)"/>
    </xsl:template>

    <xsl:template match="track">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,(),false(),$fileset)"/>
    </xsl:template>


    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  SVG                                                                        |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->

    <!--See http://www.w3.org/TR/SVGTiny12/linking.html-->

    <xsl:template match="svg:animation">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,'application/svg+xml',false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:audio">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,@type,true(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:foreignObject[@xlink:href]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,(),false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:font-face-uri">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,(),false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:handler[@xlink:href]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,@type,false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:image">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,@type,false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:script[@xlink:href]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,@type,false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="svg:video">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@xlink:href,@type,true(),$fileset)"/>
    </xsl:template>

    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  MathML                                                                     |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->

    <xsl:template match="m:annotation[@src]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,@encoding,false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="m:math[@altimg]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@altimg,(),false(),$fileset)"/>
    </xsl:template>

    <xsl:template match="m:mglyph[@src]">
        <xsl:param name="fileset" tunnel="yes"/>
        <xsl:sequence select="f:fileset-entry(@src,(),false(),$fileset)"/>
    </xsl:template>

    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  Constructs a single fileset entry                                          |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->
    <xsl:function name="f:fileset-entry" as="element()?">
        <xsl:param name="uri" as="item()"/>
        <!--string or attribute-->
        <xsl:param name="type" as="xs:string?"/>
        <xsl:param name="allow-remote" as="xs:boolean?"/>
        <xsl:param name="fileset" as="document-node()"/>
        <xsl:variable name="href" select="pf:normalize-uri($uri)"/>
        <xsl:choose>
            <xsl:when test="not($href)"/>
            <!--ignore empty href-->
            <xsl:when test="starts-with($href,'file:')">
                <d:file href="{pf:relativize-uri($href,$doc-base)}" original-href="{f:original-href($href, (), $fileset)}">
                    <xsl:if test="$type">
                        <xsl:attribute name="media-type" select="$type"/>
                    </xsl:if>
                </d:file>
            </xsl:when>
            <xsl:when test="pf:is-absolute($href) and not($allow-remote)">
                <xsl:message><![CDATA[[WARNING] remote resource ']]><xsl:value-of select="$href"
                    /><![CDATA[' should be made local.]]></xsl:message>
            </xsl:when>
            <xsl:when test="$uri instance of attribute()">
                <!--try to get the pre-computed original href from the parent element-->
                <xsl:variable name="original-href" select="f:original-href($href, $uri/.., $fileset)"/>
                <d:file href="{$href}">
                    <xsl:if test="$type">
                        <xsl:attribute name="media-type" select="$type"/>
                    </xsl:if>
                    <xsl:if test="$original-href">
                        <xsl:attribute name="original-href" select="$original-href"/>
                    </xsl:if>
                </d:file>
            </xsl:when>
            <xsl:otherwise>
                <!--use the href itself as the original href-->
                <d:file href="{$href}" original-href="{$href}">
                    <xsl:if test="$type">
                        <xsl:attribute name="media-type" select="$type"/>
                    </xsl:if>
                </d:file>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  Media Type Utils                                                           |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->
    <xsl:function name="f:is-audio" as="xs:boolean">
        <xsl:param name="uri" as="item()?"/>
        <xsl:param name="type" as="item()?"/>
        <xsl:sequence
            select="starts-with($type,'audio/') 
            or pf:get-extension($uri)=('m4a','mp3','aac','aiff','ogg','wav','wvma','flac','mpa','spx','oga','3gp')"
        />
    </xsl:function>
    <xsl:function name="f:is-video" as="xs:boolean">
        <xsl:param name="uri" as="item()?"/>
        <xsl:param name="type" as="item()?"/>
        <xsl:sequence
            select="starts-with($type,'video/') 
            or pf:get-extension($uri)=('mp4','mpeg','m4v','mp4','flv','wmv','mov','ogv')"
        />
    </xsl:function>


    <!--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––>
     |  Extract URLs from CSS                                                      |
    <|–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-->
    <xsl:function name="f:get-css-resources" as="xs:string*">
        <xsl:param name="css" as="xs:string"/>
        <xsl:param name="css-base" as="xs:string"/>
        <xsl:analyze-string select="$css" regex="@import\s+(.*?)(\s*|\s+[^)].*);">
            <xsl:matching-substring>
                <xsl:variable name="url"
                    select="f:parse-css-url(replace(regex-group(1),'^url\(\s*(.*?)\s*\)$','$1'))"/>
                <!--TODO remove query fragments, check that URL is relative-->
                <xsl:sequence
                    select="if ($url and unparsed-text-available(resolve-uri($url,$css-base))) 
                    then f:get-css-resources(unparsed-text(resolve-uri($url,$css-base)),resolve-uri($url,$css-base))
                    else ()"
                />
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="url\(\s*(.*?)\s*\)">
                    <xsl:matching-substring>
                        <xsl:variable name="url" select="f:parse-css-url(regex-group(1))"/>
                        <xsl:sequence select="if ($url) then resolve-uri($url,$css-base) else ()"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="f:parse-css-url" as="xs:string?">
        <xsl:param name="url" as="xs:string"/>
        <xsl:sequence
            select="
            if (matches($url,'''(.*?)''')) then replace($url,'''(.*?)''','$1') 
            else if  (matches($url,'&quot;(.*?)&quot;')) then replace($url,'&quot;(.*?)&quot;','$1')
            else if (matches($url,'^[^''&quot;]')) then $url
            else ()"
        />
    </xsl:function>
    
    <xsl:function name="f:original-href">
        <xsl:param name="href-attribute" as="xs:string"/>
        <xsl:param name="context-element"/>
        <xsl:param name="fileset" as="document-node()"/>
        <xsl:choose>
            <xsl:when test="$context-element">
                <xsl:variable name="resolved-href" select="pf:normalize-uri(string(resolve-uri($href-attribute,base-uri($context-element))))"/>
                <xsl:variable name="original-href" select="if ($context-element/@data-original-href) then pf:normalize-uri(string(resolve-uri($context-element/@data-original-href,base-uri($context-element)))) else if ($fileset//d:file[@href=$resolved-href]) then $fileset//d:file[@href=$resolved-href]/@original-href else $resolved-href"/>
                <xsl:value-of select="$original-href"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="resolved-href" select="pf:normalize-uri($href-attribute)"/>
                <xsl:variable name="original-href" select="if ($fileset//d:file[@href=$resolved-href]) then $fileset//d:file[@href=$resolved-href]/@original-href else $resolved-href"/>
                <xsl:value-of select="$original-href"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
