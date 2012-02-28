<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:h="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="#all">

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/">
        <xsl:for-each select="*|text()|processing-instruction()|comment()">
            <xsl:copy>
                <xsl:apply-templates select="."/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="text()|processing-instruction()|comment()">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template name="html" match="h:html">
        <xsl:copy-of select="@id|@lang|@dir|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:head|self::h:body|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('head','body')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='head'">
                                        <xsl:call-template name="head"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='body'">
                                        <xsl:call-template name="body"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <head xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="head"/>
                            </head>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="head" match="h:head">
        <xsl:copy-of select="@id|@lang|@dir|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:title|self::h:base|self::h:base|self::h:title|self::h:script|self::h:style|self::h:meta|self::h:link|self::h:object|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('title','base','base','title','script','style','meta','link','object')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='title'">
                                        <xsl:call-template name="title"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='base'">
                                        <xsl:call-template name="base"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='base'">
                                        <xsl:call-template name="base"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='title'">
                                        <xsl:call-template name="title"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='style'">
                                        <xsl:call-template name="style"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='meta'">
                                        <xsl:call-template name="meta"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='link'">
                                        <xsl:call-template name="link"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <title xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="title"/>
                            </title>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="title" match="h:title">
        <xsl:copy-of select="@id|@lang|@dir|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="base" match="h:base">
        <xsl:copy-of select="@href|@id|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="meta" match="h:meta">
        <xsl:copy-of
            select="@id|@http-equiv|@name|@content|@lang|@dir|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="link" match="h:link">
        <xsl:copy-of
            select="@href|@hreflang|@type|@rel|@media|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="style" match="h:style">
        <xsl:copy-of
            select="@id|@type|@media|@title|@lang|@dir|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="script" match="h:script">
        <xsl:copy-of select="@id|@charset|@type|@src|@defer|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="noscript" match="h:noscript">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <div xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="div"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="body" match="h:body">
        <xsl:copy-of
            select="@onload|@onunload|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <div xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="div"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="div" match="h:div">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="p" match="h:p">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="h1" match="h:h1">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="h2" match="h:h2">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="h3" match="h:h3">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="h4" match="h:h4">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="h5" match="h:h5">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="h6" match="h:h6">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ul" match="h:ul">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:li|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('li')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='li'">
                                        <xsl:call-template name="li"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <li xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="li"/>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ol" match="h:ol">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:li|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('li')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='li'">
                                        <xsl:call-template name="li"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <li xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="li"/>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="li" match="h:li">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="dl" match="h:dl">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:dt|self::h:dd|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('dt','dd')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='dt'">
                                        <xsl:call-template name="dt"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dd'">
                                        <xsl:call-template name="dd"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <dt xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="dt"/>
                            </dt>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="dt" match="h:dt">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="dd" match="h:dd">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="address" match="h:address">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="hr" match="h:hr">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="pre" match="h:pre">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:a|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:ins|self::h:del|self::h:script|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('a','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','ins','del','script')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="blockquote" match="h:blockquote">
        <xsl:copy-of
            select="@cite|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <div xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="div"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ins" match="h:ins">
        <xsl:copy-of
            select="@cite|@datetime|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="del" match="h:del">
        <xsl:copy-of
            select="@cite|@datetime|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="a" match="h:a">
        <xsl:copy-of
            select="@type|@href|@hreflang|@rel|@accesskey|@tabindex|@onfocus|@onblur|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:ins|self::h:del|self::h:script|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','ins','del','script')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="span" match="h:span">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="bdo" match="h:bdo">
        <xsl:copy-of
            select="@lang|@dir|@id|@class|@style|@title|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="br" match="h:br">
        <xsl:copy-of select="@id|@class|@style|@title|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="em" match="h:em">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="strong" match="h:strong">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="dfn" match="h:dfn">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="code" match="h:code">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="samp" match="h:samp">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="kbd" match="h:kbd">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="var" match="h:var">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="cite" match="h:cite">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="abbr" match="h:abbr">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="acronym" match="h:acronym">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="q" match="h:q">
        <xsl:copy-of
            select="@cite|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="sub" match="h:sub">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="sup" match="h:sup">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="tt" match="h:tt">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="i" match="h:i">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="b" match="h:b">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="big" match="h:big">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="small" match="h:small">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="object" match="h:object">
        <xsl:copy-of
            select="@data|@type|@height|@width|@usemap|@name|@tabindex|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:param|self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('param','form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='param'">
                                        <xsl:call-template name="param"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="param" match="h:param">
        <xsl:copy-of select="@id|@name|@value|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="img" match="h:img">
        <xsl:copy-of
            select="@src|@alt|@height|@width|@usemap|@ismap|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="map" match="h:map">
        <xsl:copy-of
            select="@id|@class|@style|@title|@name|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:area|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','area','noscript','ins','del','script','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='area'">
                                        <xsl:call-template name="area"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <div xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="div"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="area" match="h:area">
        <xsl:copy-of
            select="@shape|@coords|@href|@alt|@accesskey|@tabindex|@onfocus|@onblur|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="form" match="h:form">
        <xsl:copy-of
            select="@action|@method|@enctype|@onsubmit|@onreset|@accept|@accept-charset|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('noscript','ins','del','script','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <div xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="div"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="label" match="h:label">
        <xsl:copy-of
            select="@for|@accesskey|@onfocus|@onblur|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="input" match="h:input">
        <xsl:copy-of
            select="@type|@name|@value|@checked|@disabled|@readonly|@size|@maxlength|@src|@alt|@onselect|@onchange|@accept|@accesskey|@tabindex|@onfocus|@onblur|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="select" match="h:select">
        <xsl:copy-of
            select="@name|@size|@multiple|@disabled|@tabindex|@onfocus|@onblur|@onchange|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:optgroup|self::h:option|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('optgroup','option')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='optgroup'">
                                        <xsl:call-template name="optgroup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='option'">
                                        <xsl:call-template name="option"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <optgroup xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="optgroup"/>
                            </optgroup>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="optgroup" match="h:optgroup">
        <xsl:copy-of
            select="@disabled|@label|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:option|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('option')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='option'">
                                        <xsl:call-template name="option"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <option xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="option"/>
                            </option>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="option" match="h:option">
        <xsl:copy-of
            select="@selected|@disabled|@label|@value|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="textarea" match="h:textarea">
        <xsl:copy-of
            select="@name|@rows|@cols|@disabled|@readonly|@onselect|@onchange|@accesskey|@tabindex|@onfocus|@onblur|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="fieldset" match="h:fieldset">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:legend|self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('legend','form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='legend'">
                                        <xsl:call-template name="legend"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="legend" match="h:legend">
        <xsl:copy-of
            select="@accesskey|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="button" match="h:button">
        <xsl:copy-of
            select="@name|@value|@type|@disabled|@accesskey|@tabindex|@onfocus|@onblur|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:p|self::h:div|self::h:table|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('p','div','table','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','noscript','ins','del','script','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="table" match="h:table">
        <xsl:copy-of
            select="@border|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:caption|self::h:col|self::h:colgroup|self::h:thead|self::h:tfoot|self::h:tbody|self::h:tr|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('caption','col','colgroup','thead','tfoot','tbody','tr')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='caption'">
                                        <xsl:call-template name="caption"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='col'">
                                        <xsl:call-template name="col"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='colgroup'">
                                        <xsl:call-template name="colgroup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='thead'">
                                        <xsl:call-template name="thead"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='tfoot'">
                                        <xsl:call-template name="tfoot"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='tbody'">
                                        <xsl:call-template name="tbody"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='tr'">
                                        <xsl:call-template name="tr"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <caption xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="caption"/>
                            </caption>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="caption" match="h:caption">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="thead" match="h:thead">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:tr|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('tr')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='tr'">
                                        <xsl:call-template name="tr"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="tr"/>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="tfoot" match="h:tfoot">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:tr|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('tr')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='tr'">
                                        <xsl:call-template name="tr"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="tr"/>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="tbody" match="h:tbody">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:tr|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('tr')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='tr'">
                                        <xsl:call-template name="tr"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="tr"/>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="colgroup" match="h:colgroup">
        <xsl:copy-of
            select="@span|@width|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@align|@char|@charoff|@valign|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:col|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('col')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='col'">
                                        <xsl:call-template name="col"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <col xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="col"/>
                            </col>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="col" match="h:col">
        <xsl:copy-of
            select="@span|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="text()|comment()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="tr" match="h:tr">
        <xsl:copy-of
            select="@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when test="self::h:th|self::h:td|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('th','td')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='th'">
                                        <xsl:call-template name="th"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='td'">
                                        <xsl:call-template name="td"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <th xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="th"/>
                            </th>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="th" match="h:th">
        <xsl:copy-of
            select="@headers|@scope|@rowspan|@colspan|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="td" match="h:td">
        <xsl:copy-of
            select="@headers|@scope|@rowspan|@colspan|@id|@class|@style|@title|@lang|@dir|@onclick|@ondblclick|@onmousedown|@onmouseup|@onmouseover|@onmousemove|@onmouseout|@onkeypress|@onkeydown|@onkeyup|@*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml')) or starts-with(local-name(),'data-')]"/>
        <xsl:for-each select="*|text()|comment()">
            <xsl:choose>
                <xsl:when
                    test="self::h:form|self::h:noscript|self::h:ins|self::h:del|self::h:script|self::h:a|self::h:object|self::h:img|self::h:br|self::h:span|self::h:bdo|self::h:map|self::h:i|self::h:b|self::h:small|self::h:em|self::h:strong|self::h:dfn|self::h:code|self::h:q|self::h:samp|self::h:kbd|self::h:var|self::h:cite|self::h:abbr|self::h:sub|self::h:sup|self::h:input|self::h:select|self::h:textarea|self::h:label|self::h:button|self::h:p|self::h:div|self::h:fieldset|self::h:table|self::h:h1|self::h:h2|self::h:h3|self::h:h4|self::h:h5|self::h:h6|self::h:ul|self::h:ol|self::h:dl|self::h:pre|self::h:hr|self::h:blockquote|self::h:address|self::*[not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))]">
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="self::*">
                    <xsl:variable name="replaceWith"
                        select="if (not(namespace-uri()=('','http://www.w3.org/1999/xhtml'))) then '' else if (local-name()='applet') then 'object' else if (local-name()='acronym') then 'abbr' else if (local-name()='bgsound') then 'audio' else if (local-name()='dir') then 'ul' else if (local-name()='frame') then 'iframe' else if (local-name()='frameset') then 'div' else if (local-name()='noframes') then 'div' else if (local-name()='listing') then 'pre' else if (local-name()='noembed') then 'object' else if (local-name()='strike') then 's' else if (local-name()='xmp') then 'code' else ''"/>
                    <xsl:choose>
                        <xsl:when
                            test="namespace-uri()=('','http://www.w3.org/1999/xhtml') and $replaceWith=('form','noscript','ins','del','script','a','object','img','br','span','bdo','map','i','b','small','em','strong','dfn','code','q','samp','kbd','var','cite','abbr','sub','sup','input','select','textarea','label','button','p','div','fieldset','table','h1','h2','h3','h4','h5','h6','ul','ol','dl','pre','hr','blockquote','address')">
                            <xsl:element name="{$replaceWith}" namespace="http://www.w3.org/1999/xhtml">
                                <xsl:choose>
                                    <xsl:when test="$replaceWith='form'">
                                        <xsl:call-template name="form"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='noscript'">
                                        <xsl:call-template name="noscript"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ins'">
                                        <xsl:call-template name="ins"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='del'">
                                        <xsl:call-template name="del"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='script'">
                                        <xsl:call-template name="script"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='a'">
                                        <xsl:call-template name="a"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='object'">
                                        <xsl:call-template name="object"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='img'">
                                        <xsl:call-template name="img"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='br'">
                                        <xsl:call-template name="br"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='span'">
                                        <xsl:call-template name="span"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='bdo'">
                                        <xsl:call-template name="bdo"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='map'">
                                        <xsl:call-template name="map"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='i'">
                                        <xsl:call-template name="i"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='b'">
                                        <xsl:call-template name="b"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='small'">
                                        <xsl:call-template name="small"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='em'">
                                        <xsl:call-template name="em"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='strong'">
                                        <xsl:call-template name="strong"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dfn'">
                                        <xsl:call-template name="dfn"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='code'">
                                        <xsl:call-template name="code"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='q'">
                                        <xsl:call-template name="q"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='samp'">
                                        <xsl:call-template name="samp"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='kbd'">
                                        <xsl:call-template name="kbd"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='var'">
                                        <xsl:call-template name="var"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='cite'">
                                        <xsl:call-template name="cite"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='abbr'">
                                        <xsl:call-template name="abbr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sub'">
                                        <xsl:call-template name="sub"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='sup'">
                                        <xsl:call-template name="sup"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='input'">
                                        <xsl:call-template name="input"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='select'">
                                        <xsl:call-template name="select"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='textarea'">
                                        <xsl:call-template name="textarea"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='label'">
                                        <xsl:call-template name="label"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='button'">
                                        <xsl:call-template name="button"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='p'">
                                        <xsl:call-template name="p"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='div'">
                                        <xsl:call-template name="div"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='fieldset'">
                                        <xsl:call-template name="fieldset"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='table'">
                                        <xsl:call-template name="table"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h1'">
                                        <xsl:call-template name="h1"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h2'">
                                        <xsl:call-template name="h2"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h3'">
                                        <xsl:call-template name="h3"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h4'">
                                        <xsl:call-template name="h4"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h5'">
                                        <xsl:call-template name="h5"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='h6'">
                                        <xsl:call-template name="h6"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ul'">
                                        <xsl:call-template name="ul"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='ol'">
                                        <xsl:call-template name="ol"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='dl'">
                                        <xsl:call-template name="dl"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='pre'">
                                        <xsl:call-template name="pre"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='hr'">
                                        <xsl:call-template name="hr"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='blockquote'">
                                        <xsl:call-template name="blockquote"/>
                                    </xsl:when>
                                    <xsl:when test="$replaceWith='address'">
                                        <xsl:call-template name="address"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:call-template name="span"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>



</xsl:stylesheet>
