<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:mediaoverlay-join" version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:epub="http://www.idpf.org/2007/ops" xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc">
    <p:input port="source" sequence="true"/>
    <p:output port="result"/>

    <p:for-each>
        <p:add-xml-base/>
        <p:xslt>
            <p:with-param name="id-prefix" select="concat('mo',p:iteration-position(),'_')"/>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                        <xsl:param name="id-prefix" required="yes"/>
                        <xsl:variable name="xml-base"
                            select="replace(/*/@xml:base,'^(.+/)[^/]*$','$1')"/>
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="mo:body">
                            <seq xmlns="http://www.w3.org/ns/SMIL">
                                <xsl:apply-templates select="@*"/>
                                <xsl:attribute name="xml:base" select="$xml-base"/>
                                <xsl:apply-templates select="node()"/>
                            </seq>
                        </xsl:template>
                        <xsl:template match="*[@id and ancestor::mo:body]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:attribute name="id" select="concat($id-prefix,@id)"/>
                                <xsl:if test="self::mo:text">
                                    <xsl:attribute name="src"
                                        select="concat(resolve-uri(tokenize(@src,'#')[1],$xml-base),'#',tokenize(@src,'#')[last()])"
                                    />
                                </xsl:if>
                                <xsl:apply-templates select="node()"/>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
    </p:for-each>
    <p:wrap-sequence wrapper="body" wrapper-namespace="http://www.w3.org/ns/SMIL"/>
    <p:wrap-sequence wrapper="smil" wrapper-namespace="http://www.w3.org/ns/SMIL"/>
    <p:choose>
        <p:when test="/mo:smil/descendant::mo:smil/@id">
            <p:add-attribute attribute-name="id" match="/*">
                <p:with-option name="attribute-value" select="(/mo:smil/descendant::mo:smil/@id)[1]"
                />
            </p:add-attribute>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <p:add-attribute attribute-name="profile"
        attribute-value="http://www.idpf.org/epub/30/profile/content/" match="/*"/>
    <p:add-attribute attribute-name="version" attribute-value="3.0" match="/*"/>
    <p:unwrap match="/*/*/*"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                    <xsl:variable name="base" select="f:longest-common-uri(//@xml:base)"/>
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="xml:base" select="$base"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="mo:text">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <!-- TODO: handle @textrefs for seqs and bodys and @src for audio like in rearrange.xpl -->
                            <xsl:attribute name="src"
                                select="concat(f:relative-to(tokenize(@src,'#')[1],$base),'#',tokenize(@src,'#')[last()])"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:function name="f:longest-common-uri">
                        <xsl:param name="uris"/>
                        <xsl:choose>
                            <xsl:when test="count($uris)=1">
                                <xsl:value-of select="replace($uris[1],'^(.+/)[^/]*$','$1')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="a"
                                    select="replace($uris[1],'^(.+/)[^/]*$','$1')"/>
                                <xsl:variable name="b"
                                    select="replace($uris[2],'^(.+/)[^/]*$','$1')"/>
                                <xsl:variable name="longest"
                                    select="if (string-length($a) &gt; string-length($b))
                                                then
                                                    substring($a,0,string-length($a)-string-length(substring-after($a,$b))+1)
                                                else
                                                    substring($b,0,string-length($b)-string-length(substring-after($b,$a))+1)"/>
                                <xsl:value-of
                                    select="f:longest-common-uri(insert-before(subsequence($uris,3),0,$longest))"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:function>
                    <xsl:function name="f:relative-to">
                        <xsl:param name="uri"/>
                        <xsl:param name="base"/>
                        <xsl:variable name="basedir" select="replace($base,'^(.+/)[^/]*$','$1')"/>
                        <xsl:variable name="relative"
                            select="substring($uri,string-length($basedir)+1)"/>
                        <xsl:value-of select="$relative"/>
                    </xsl:function>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:delete match="/*/descendant::*/@xml:base"/>
</p:declare-step>
