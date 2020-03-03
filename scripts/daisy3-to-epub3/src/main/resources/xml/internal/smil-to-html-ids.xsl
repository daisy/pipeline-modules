<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:smil="http://www.w3.org/2001/SMIL20/"
                xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="#all">

    <!--
        It is assumed that SMIL and content documents have been prepared so that all ID attributes
        are unique in the whole publication.
    -->

    <xsl:variable name="dtbook-smils" select="collection()[/smil:smil]"/>
    <xsl:variable name="dtbooks" select="collection()[/dtbook:dtbook]"/>

    <xsl:template name="create-id-map">
        <d:idmap>
            <xsl:for-each select="$dtbook-smils">
                <d:smil>
                    <xsl:variable name="smil-uri" select="base-uri(.)"/>
                    <xsl:attribute name="xml:base" select="$smil-uri"/>
                    <xsl:apply-templates select="/*">
                        <xsl:with-param name="smil-uri" tunnel="yes" select="$smil-uri"/>
                    </xsl:apply-templates>
                </d:smil>
            </xsl:for-each>
        </d:idmap>
    </xsl:template>

    <xsl:template match="smil:text[@id]|
                         smil:*[@id][count(smil:text)=1]">
        <xsl:variable name="smil-id" select="@id"/>
        <xsl:variable name="html-id" select="substring-after(descendant-or-self::smil:text/@src,'#')"/>
        <d:id smil-id="{$smil-id}"
              html-id="{$html-id}"/>
    </xsl:template>

    <xsl:template match="smil:seq[@id]">
        <xsl:param name="smil-uri" tunnel="yes" required="yes"/>
        <xsl:variable name="smil-id" select="@id"/>
        <xsl:variable name="dtbook-smilref" as="attribute()?"
                      select="$dtbooks//@smilref[substring-after(.,'#')=$smil-id]
                                                [resolve-uri(substring-before(.,'#'),base-uri(..))=$smil-uri]
                                                [1]"/>
        <xsl:if test="exists($dtbook-smilref/../@id)">
            <xsl:variable name="html-id" select="$dtbook-smilref/../@id"/>
            <d:id smil-id="{$smil-id}"
                  html-id="{$html-id}"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="@*|*">
        <xsl:apply-templates select="@*|*"/>
    </xsl:template>

</xsl:stylesheet>
