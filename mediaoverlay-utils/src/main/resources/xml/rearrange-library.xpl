<?xml version="1.0" encoding="UTF-8"?>
<p:library exclude-inline-prefixes="#all" version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:epub="http://www.idpf.org/2007/ops" xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal">

    <p:declare-step name="rearrange.subcontent"
        type="pxi:mediaoverlay-internal-rearrange-subcontent">
        <p:input port="content" primary="true"/>
        <p:input port="mediaoverlay"/>
        <p:output port="result" sequence="true"/>

        <p:variable name="name" select="name(/*)"/>
        <p:variable name="id" select="/*/@id"/>
        <p:variable name="src" select="/*/@xml:base"/>
        <p:variable name="type" select="/*/@epub:type"/>

        <p:for-each name="rearrange.subcontent.recursion">
            <p:output port="result" sequence="true"/>
            <p:iteration-source select="/*/*"/>
            <!--pxi:mediaoverlay-internal-rearrange-subcontent>
                <p:input port="mediaoverlay">
                    <p:pipe port="mediaoverlay" step="rearrange.subcontent"/>
                </p:input>
                </pxi:mediaoverlay-internal-rearrange-subcontent-->
            <p:identity/>
        </p:for-each>
        <p:sink/>

        <p:choose>
            <p:xpath-context>
                <p:pipe port="mediaoverlay" step="rearrange.subcontent"/>
            </p:xpath-context>
            <p:when
                test="string-length($id) &gt; 0 and string-length($src) &gt; 0 and //*[@fragment=$id and @src=$src]">
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:inline><![CDATA[]]><text xmlns="http://www.w3.org/ns/SMIL"
                            /><![CDATA[]]></p:inline>
                    </p:input>
                </p:identity>
                <p:add-attribute attribute-name="src" match="/*">
                    <p:with-option name="attribute-value" select="$src"/>
                </p:add-attribute>
                <p:add-attribute attribute-name="fragment" match="/*">
                    <p:with-option name="attribute-value" select="$id"/>
                </p:add-attribute>
                <p:wrap match="/*" wrapper="par" wrapper-namespace="http://www.w3.org/ns/SMIL"/>
                <p:choose>
                    <p:when test="string-length($type) &gt; 0">
                        <p:add-attribute attribute-name="epub:type" match="/*">
                            <p:with-option name="attribute-value" select="$type"/>
                        </p:add-attribute>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
                <p:identity name="rearrange.subcontent.par"/>
                <p:sink/>

                <p:xslt>
                    <p:input port="source">
                        <p:pipe port="mediaoverlay" step="rearrange.subcontent"/>
                    </p:input>
                    <p:with-param name="src" select="$src"/>
                    <p:with-param name="fragment" select="$id"/>
                    <p:input port="stylesheet">
                        <p:document href="get-audioclip-by-href.xsl"/>
                    </p:input>
                </p:xslt>
                <p:identity name="rearrange.subcontent.audio"/>
                <p:sink/>

                <p:insert match="/*" position="last-child">
                    <p:input port="source">
                        <p:pipe port="result" step="rearrange.subcontent.par"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="rearrange.subcontent.audio"/>
                    </p:input>
                </p:insert>
            </p:when>
            <p:when test="string-length($id) &gt; 0">
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:inline><![CDATA[]]><seq xmlns="http://www.w3.org/ns/SMIL"
                            /><![CDATA[]]></p:inline>
                    </p:input>
                </p:identity>
                <p:add-attribute attribute-name="src" match="/*">
                    <p:with-option name="attribute-value" select="$src"/>
                </p:add-attribute>
                <p:add-attribute attribute-name="fragment" match="/*">
                    <p:with-option name="attribute-value" select="$id"/>
                </p:add-attribute>
                <p:choose>
                    <p:when test="string-length($type) &gt; 0">
                        <p:add-attribute attribute-name="epub:type" match="/*">
                            <p:with-option name="attribute-value" select="$type"/>
                        </p:add-attribute>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
                <p:insert match="/*" position="last-child">
                    <p:input port="insertion">
                        <p:pipe port="result" step="rearrange.subcontent.recursion"/>
                    </p:input>
                </p:insert>
            </p:when>
            <p:otherwise>
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="rearrange.subcontent.recursion"/>
                    </p:input>
                </p:identity>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>

</p:library>
