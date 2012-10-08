<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-pub-assign-media-overlays" name="main" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions" xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:err="http://www.w3.org/ns/xproc-error" version="1.0">

    <p:input port="package" primary="true"/>
    <p:input port="media-overlay" sequence="true"/>
    <p:output port="result" sequence="true"/>
    <p:option name="package-uri" required="false" select="''"/>
    <p:variable name="packageUri" select="if ($package-uri='') then base-uri(/*) else $package-uri">
        <p:pipe port="package" step="main"/>
    </p:variable>
    
    <p:for-each>
        <p:iteration-source>
            <p:pipe port="media-overlay" step="main"/>
        </p:iteration-source>
        
        <p:variable name="mo-base" select="base-uri(/*)"/>
        <p:for-each>
            <p:iteration-source select="//mo:text"/>
            <p:variable name="mo-src" select="resolve-uri(tokenize(/*/@src,'#')[1],$mo-base)"/>
            <p:add-attribute match="/*" attribute-name="href">
                <p:input port="source">
                    <p:inline exclude-inline-prefixes="#all">
                        <d:content/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value" select="$mo-src"/>
            </p:add-attribute>
        </p:for-each>
        <p:wrap-sequence wrapper="d:mo"/>
        <p:add-attribute match="/*" attribute-name="href">
            <p:with-option name="attribute-value" select="$mo-base"/>
        </p:add-attribute>
        
        <p:xslt>
            <!-- Removing duplicates here as well (and not only in the end) should improve performance. I think. -->
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="assign-media-overlays.remove-duplicates.xsl"/>
            </p:input>
        </p:xslt>
        
    </p:for-each>
    <p:wrap-sequence wrapper="d:mo-content-mapping"/>

    <p:xslt name="mapping">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="assign-media-overlays.remove-duplicates.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:insert match="/*" position="first-child">
        <p:input port="source">
            <p:pipe port="package" step="main"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="mapping"/>
        </p:input>
    </p:insert>
    <p:xslt>
        <p:with-param name="package-uri" select="$packageUri"/>
        <p:input port="stylesheet">
            <p:document href="assign-media-overlays.assign-media-overlays.xsl"/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
