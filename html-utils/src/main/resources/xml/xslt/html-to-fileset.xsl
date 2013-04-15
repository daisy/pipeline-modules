<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    
    <!--    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>-->
    
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    
    <xsl:template match="text()"/>
    
    <xsl:variable name="doc-base"
        select="if (/html/head/base[@href][1]) then resolve-uri(normalize-space(/html/head/base[@href][1]/@href),base-uri(/)) else base-uri(/)"/>
    
    <!--TODO handle SVG references-->
    <!--TODO filter references to self-->
    
    <xsl:template match="/*">
        <!--
        Builds a file set with all the resources referenced from the HTML.
        Some media types are inferred – users may have to apply additional type detection.
        -->
        <d:fileset>
            <xsl:attribute name="xml:base" select="replace($doc-base,'^(.+/)[^/]*','$1')"/>
            <xsl:apply-templates/>
        </d:fileset>
    </xsl:template>
    
    
    <xsl:template match="/processing-instruction('xml-stylesheet')">
        <xsl:variable name="href" select="replace(.,'^.*href=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:variable name="type" select="replace(.,'^.*type=(&amp;apos;|&quot;)(.*?)\1.*$','$2')"/>
        <xsl:sequence
            select="f:fileset-entry($href,
            if ($type) then $type
            else if (matches($href,'.*\.css$','i')) then 'text/css'
            else if (matches($href,'.*\.xslt?$','i')) then 'application/xslt+xml'
            else '',())"
        />
    </xsl:template>
    
    <xsl:template match="link">
        <!--
            External resources: icon, prefetch, stylesheet + pronunciation
            Hyperlinks:  alternate, author, help, license, next, prev, search
        -->
        <!--Note: outbound hyperlinks that resolve outside the EPUB Container are not Publication Resources-->
        <!--TODO warning for remote external resources, ignore remote hyperlinks -->
        <xsl:variable name="rel" as="xs:string*" select="tokenize(@rel,'\s+')"/>
        <xsl:if test="$rel=('stylesheet','pronunciation')">
            <xsl:sequence
                select="f:fileset-entry(normalize-space(@href),
                if (@type) then @type
                else if (matches(@href,'.*\.css$','i')) then 'text/css'
                else if (matches(@href,'.*\.xslt?$','i')) then 'application/xslt+xml'
                else if (matches(@href,'.*\.pls$','i')) then 'application/pls+xml'
                else '',resolve-uri(@data-original-href,base-uri()))"
            />
        </xsl:if>
        <!--TODO parse refs in CSS-->
    </xsl:template>
    
    <!--<xsl:template match="style">
        <xsl:for-each select="f:get-css-resources(.,$doc-base)">
            <d:file href="{.}"/>
        </xsl:for-each>
    </xsl:template>-->
    
    <xsl:template match="script[@src]">
        <!--TODO handle 'script' with @src-->
    </xsl:template>
    
    <xsl:template match="a[@href]">
        <xsl:variable name="href" select="tokenize(@href,'#')[1]"/>
        <!--<xsl:if test="not(matches(normalize-space(@href),'^[^/]+:.*'))">
            <xsl:sequence select="f:fileset-entry(normalize-space(@href),@type,@data-original-href)"/>
        </xsl:if>-->
    </xsl:template>
    
    
    <xsl:template match="img[@src]">
        <xsl:sequence
            select="f:fileset-entry(normalize-space(@src),
            if (matches(@src,'.*\.png$','i')) then 'image/png'
            else if (matches(@src,'.*\.jpe?g$','i')) then 'image/jpeg'
            else if (matches(@src,'.*\.gif$','i')) then 'image/gif'
            else if (matches(@src,'.*\.svg$','i')) then 'image/xml+svg'
            else '',resolve-uri(@data-original-href,base-uri()))"
        />
    </xsl:template>
    
    <xsl:template match="iframe">
        <!--TODO handle 'iframe'-->
    </xsl:template>
    
    <xsl:template match="embed">
        <!--TODO handle 'embed'(note: no content fallback)-->
    </xsl:template>
    
    <xsl:template match="object">
        <!--TODO handle 'object' with @data-->
    </xsl:template>
    
    <!--TODO handle audio-->
    <!--TODO handle video-->
    
    <xsl:template match="source">
        <!--TODO handle 'source'-->
    </xsl:template>
    
    <xsl:template match="track">
        <!--TODO handle 'track'-->
    </xsl:template>
    
    <xsl:function name="f:fileset-entry" as="element()">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="type" as="xs:string?"/>
        <xsl:param name="original-href" as="xs:string?"/>
        <d:file href="{$href}">
            <xsl:if test="$type">
                <xsl:attribute name="media-type" select="$type"/>
            </xsl:if>
            <xsl:if test="$original-href">
                <xsl:attribute name="original-href" select="$original-href"/>
            </xsl:if>
        </d:file>
    </xsl:function>
    
    <xsl:function name="f:get-css-resources" as="xs:string*">
        <xsl:param name="css" as="xs:string"/>
        <xsl:param name="css-base" as="xs:string"/>
        <xsl:analyze-string select="$css" regex="@import\s+(.*?)(\s*|\s+[^)].*);">
            <xsl:matching-substring>
                <xsl:variable name="url"
                    select="f:parse-url(replace(regex-group(1),'^url\(\s*(.*?)\s*\)$','$1'))"/>
                <!--TODO remove query fragments, check that URL is relative-->
                <xsl:sequence
                    select="if ($url and unparsed-text-available(resolve-uri($url,$css-base))) 
                    then f:get-css-resources(unparsed-text(resolve-uri($url,$css-base)),$url)
                    else ()"
                />
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="url\(\s*(.*?)\s*\)">
                    <xsl:matching-substring>
                        <xsl:sequence select="f:parse-url(regex-group(1))"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="f:parse-url" as="xs:string?">
        <xsl:param name="url" as="xs:string"/>
        <xsl:sequence
            select="
            if (matches($url,'''(.*?)''')) then replace($url,'''(.*?)''','$1') 
            else if  (matches($url,'&quot;(.*?)&quot;')) then replace($url,'&quot;(.*?)&quot;','$1')
            else if (matches($url,'^[^''&quot;]')) then $url
            else ()"
        />
    </xsl:function>
    
</xsl:stylesheet>