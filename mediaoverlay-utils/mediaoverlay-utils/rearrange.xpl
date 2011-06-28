<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="rearrange" type="px:mediaoverlay-rearrange" version="1.0"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:epub="http://www.idpf.org/2007/ops"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:di="http://www.daisy.org/ns/pipeline/tmp">

    <p:input port="mediaoverlay" primary="true" sequence="true"/>
    <p:input port="content" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:import href="rearrange-library.xpl"/>
    <p:import href="join.xpl"/>

    <px:mediaoverlay-join/>
    <p:add-xml-base all="true" relative="false"/>
    <p:viewport match="//mo:text" name="rearrange.mediaoverlay-annotated">
        <p:add-attribute attribute-name="fragment" match="/*">
            <p:with-option name="attribute-value"
                select="if (contains(/*/@src,'#')) then tokenize(/*/@src,'#')[last()] else ''"/>
        </p:add-attribute>
        <p:add-attribute attribute-name="src" match="/*">
            <p:with-option name="attribute-value"
                select="resolve-uri(tokenize(/*/@src,'#')[1],/*/@xml:base)"/>
        </p:add-attribute>
    </p:viewport>
    <p:sink/>

    <p:for-each name="rearrange.for-each">
        <p:output port="mediaoverlay" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="content" step="rearrange"/>
        </p:iteration-source>

        <p:add-xml-base all="true" relative="false" name="rearrange.for-each.content"/>
        <p:wrap-sequence wrapper="di:content-and-mediaoverlay">
            <p:input port="source">
                <p:pipe port="result" step="rearrange.for-each.content"/>
                <p:pipe port="result" step="rearrange.mediaoverlay-annotated"/>
            </p:input>
        </p:wrap-sequence>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="rearrange.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="//mo:seq[not(descendant::mo:par)]"/>

        <p:documentation>generate ids</p:documentation>
        <p:xslt>
            <p:with-param name="iteration-position" select="p:iteration-position()"/>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                        <xsl:param name="iteration-position" required="yes"/>
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="mo:body">
                            <xsl:call-template name="add-id">
                                <xsl:with-param name="id" select="concat('mo',$iteration-position)"
                                />
                            </xsl:call-template>
                        </xsl:template>
                        <xsl:template name="add-id">
                            <xsl:param name="id" required="yes"/>
                            <xsl:copy>
                                <xsl:apply-templates select="@*"/>
                                <xsl:attribute name="id" select="$id"/>
                                <xsl:for-each select="node()">
                                    <xsl:choose>
                                        <xsl:when test="self::*">
                                            <xsl:variable name="new-id"
                                                select="concat($id,
                                                                if (self::mo:seq)
                                                                    then (
                                                                        if (ancestor::mo:seq) then '-' else '_seq'
                                                                    ) else
                                                                        concat('_',local-name()),
                                                if (self::mo:text or self::mo:audio) then '' else (count(preceding-sibling::*)+1))"/>
                                            <xsl:call-template name="add-id">
                                                <xsl:with-param name="id" select="$new-id"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>

        <p:documentation>resolve relative uris</p:documentation>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                        <xsl:variable name="base"
                            select="f:longest-common-uri(distinct-values(//@src/replace(.,'^(.*/)[^/]*$','$1')))"/>
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
                        <xsl:template match="*[@src]">
                            <xsl:copy>
                                <xsl:apply-templates
                                    select="@*[not(local-name()='src') and not(local-name()='fragment')]"/>
                                <xsl:choose>
                                    <xsl:when test="self::mo:audio">
                                        <xsl:attribute name="src" select="f:relative-to(@src,$base)"
                                        />
                                    </xsl:when>
                                    <xsl:when test="self::mo:seq">
                                        <xsl:attribute name="epub:textref"
                                            select="concat(f:relative-to(@src,$base),'#',@fragment)"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="src"
                                            select="concat(f:relative-to(@src,$base),if (@fragment) then '#' else '',@fragment)"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
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

        <p:documentation>if there is only one top-level seq; turn it into a body
            element</p:documentation>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                        exclude-result-prefixes="#all">
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <xsl:copy-of select="mo:head"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="mo:body[not(@epub:textref) and not(@epub:type) and count(*)=1 and mo:seq]">
                                        <body id="{mo:body/@id}" xmlns="http://www.w3.org/ns/SMIL">
                                            <xsl:if test="mo:body/mo:seq/@epub:textref">
                                                <xsl:attribute name="epub:textref"
                                                  select="mo:body/mo:seq/@epub:textref"/>
                                            </xsl:if>
                                            <xsl:if test="mo:body/mo:seq/@epub:type">
                                                <xsl:attribute name="epub:textref"
                                                  select="mo:body/mo:seq/@epub:type"/>
                                            </xsl:if>
                                            <xsl:copy-of select="mo:body/mo:seq/*"/>
                                        </body>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="mo:body"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
    </p:for-each>

</p:declare-step>
