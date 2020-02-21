<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:s="http://www.w3.org/ns/SMIL"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns="http://www.idpf.org/2007/opf"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>

    <xsl:key name="text-refs" match="s:text/@src|@epub:textref"
             use="resolve-uri(substring-before(.,'#'),pf:base-uri(..))"/>

    <xsl:template match="opf:manifest">
        <xsl:variable name="manifest-base" select="pf:base-uri(.)"/>
        <xsl:variable name="manifest-with-smil" as="element(opf:manifest)">
            <xsl:copy>
                <xsl:sequence select="@*|opf:item"/>
                <xsl:variable name="smil-uris" select="collection()/s:smil/base-uri()"/>
                <xsl:variable name="existing-item-uris" select="opf:item/resolve-uri(@href,base-uri(.))"/>
                <xsl:variable name="new-smil-uris" select="$smil-uris[not(.=$existing-item-uris)]"/>
                <xsl:variable name="new-ids" as="xs:string*">
                    <xsl:call-template name="generate-ids">
                        <xsl:with-param name="amount" select="count($new-smil-uris)"/>
                        <xsl:with-param name="prefix" tunnel="yes" select="'item_'"/>
                        <xsl:with-param name="in-use" tunnel="yes" select="opf:item/@id"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="new-smil-items" as="element()*">
                    <xsl:for-each select="$new-smil-uris">
                        <xsl:variable name="i" select="position()"/>
                        <item id="{$new-ids[$i]}"
                              href="{pf:relativize-uri(.,$manifest-base)}"
                              media-type="application/smil+xml"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="$new-smil-items"/>
                <xsl:variable name="audio-uris" as="xs:string*">
                    <xsl:variable name="audio-uris" as="xs:string*">
                        <xsl:for-each select="collection()/s:smil">
                            <xsl:variable name="smil-base" select="base-uri(.)"/>
                            <xsl:sequence select="distinct-values(//s:audio/resolve-uri(@src,$smil-base))"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:sequence select="distinct-values($audio-uris)"/>
                </xsl:variable>
                <xsl:variable name="new-audio-uris" select="$audio-uris[not(.=$existing-item-uris)]"/>
                <xsl:variable name="mo-fileset" as="element(d:fileset)" select="collection()/d:fileset"/>
                <xsl:variable name="new-ids" as="xs:string*">
                    <xsl:call-template name="generate-ids">
                        <xsl:with-param name="amount" select="count($new-audio-uris)"/>
                        <xsl:with-param name="prefix" tunnel="yes" select="'item_'"/>
                        <xsl:with-param name="in-use" tunnel="yes" select="(opf:item/@id,$new-smil-items/@id)"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="$new-audio-uris">
                    <xsl:variable name="i" select="position()"/>
                    <xsl:variable name="audio-uri" select="."/>
                    <xsl:variable name="audio-file" as="element(d:file)?"
                                  select="$mo-fileset/d:file[resolve-uri(@href,base-uri())=$audio-uri]"/>
                    <item id="{$new-ids[$i]}"
                          href="{pf:relativize-uri($audio-uri,$manifest-base)}"
                          media-type="{$audio-file/@media-type}"/>
                </xsl:for-each>
            </xsl:copy>
        </xsl:variable>
        <xsl:for-each select="$manifest-with-smil">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="opf:item[@media-type='application/xhtml+xml']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="mo"
                          select="collection()[/s:smil]
                                              [exists(key('text-refs',current()/resolve-uri(@href,base-uri(.)),.))]"/>
            <xsl:if test="exists($mo)">
                <xsl:variable name="mo-base" select="base-uri($mo/*)"/>
                <xsl:attribute name="media-overlay" select="../opf:item[resolve-uri(@href,base-uri(.))=$mo-base]/@id"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="generate-ids">
        <xsl:param name="amount" as="xs:integer" required="yes"/>
        <xsl:param name="prefix" as="xs:string" tunnel="yes" required="yes"/>
        <xsl:param name="in-use" as="xs:string*" tunnel="yes" select="()"/>
        <xsl:param name="_feed" as="xs:integer" select="1"/>
        <xsl:variable name="id" select="concat($prefix,$_feed)"/>
        <xsl:choose>
            <xsl:when test="$id=$in-use">
                <xsl:call-template name="generate-ids">
                    <xsl:with-param name="amount" select="$amount"/>
                    <xsl:with-param name="_feed" select="$_feed + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$id"/>
                <xsl:if test="$amount &gt; 1">
                    <xsl:call-template name="generate-ids">
                        <xsl:with-param name="amount" select="$amount - 1"/>
                        <xsl:with-param name="_feed" select="$_feed + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
