<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/daisy3-to-epub3"
                type="pxi:ncx-to-nav" name="main">

    <p:input port="source" primary="true" sequence="false">
        <p:documentation>The NCX document.</p:documentation>
    </p:input>
    <p:input port="smils" sequence="true">
        <p:documentation>The DAISY 3 SMIL documents.</p:documentation>
    </p:input>
    <p:input port="dtbooks" sequence="true">
        <p:documentation>The DAISY 3 DTBook documents.</p:documentation>
    </p:input>
    <p:input port="htmls" sequence="true">
        <p:documentation>The EPUB 3 XHTML content documents.</p:documentation>
    </p:input>
    
    <p:option name="result-uri" required="true"/>

    <p:output port="fileset.out" primary="true" sequence="false">
        <p:pipe step="fileset" port="result"/>
    </p:output>
    <p:output port="in-memory.out" sequence="false">
        <p:pipe step="nav" port="result"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-create
            px:fileset-add-entry
        </p:documentation>
    </p:import>
    
    <p:group name="id-map">
        <p:output port="result"/>
        <p:xslt name="smil-to-dtbook-id" template-name="create-id-map">
            <p:input port="source">
                <p:pipe step="main" port="smils"/>
                <p:pipe step="main" port="dtbooks"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="smil-to-html-ids.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:sink/>

    <p:xslt name="nav">
        <p:input port="source">
            <p:pipe step="main" port="source"/>
            <p:pipe step="id-map" port="result"/>
            <p:pipe step="main" port="htmls"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncx-to-nav.xsl"/>
        </p:input>
        <p:with-param name="output-base-uri" select="$result-uri"/>
        <p:with-option name="output-base-uri" select="$result-uri"/>
    </p:xslt>

    <p:group name="fileset">
        <p:output port="result"/>
        <px:fileset-create>
            <p:with-option name="base" select="replace(base-uri(/*),'/[^/]*$','/')"/>
        </px:fileset-create>
        <px:fileset-add-entry media-type="application/xhtml+xml">
            <p:input port="entry">
                <p:pipe step="nav" port="result"/>
            </p:input>
        </px:fileset-add-entry>
    </p:group>

</p:declare-step>
