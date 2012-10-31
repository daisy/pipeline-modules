<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="main" type="px:dtbook-fileset" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all">

    <p:documentation>Returns a fileset based on the given DTBook.</p:documentation>

    <p:input port="source" px:media-type="application/x-dtbook+xml">
        <p:documentation>One or more DTBook files to be loaded. Any auxilliary resources referenced from the DTBook documents will be resolved based on these files.</p:documentation>
    </p:input>

    <p:output port="result">
        <p:documentation>A fileset containing references to the DTBook file and any resources it references (images etc.).</p:documentation>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="dtbook-fileset.xsl"/>
        </p:input>
    </p:xslt>
    
    <px:fileset-join/>
    
    <!-- Set the base uri for all d:file elements -->
    <p:group>
        <p:variable name="base-uri" select="/*/@xml:base"/>
        <p:viewport match="d:file">
            <p:add-attribute match="/*" attribute-name="xml:base">
                <p:with-option name="attribute-value" select="p:resolve-uri(/*/@href,$base-uri)"/>
            </p:add-attribute>
            <p:delete match="@xml:base"/>
        </p:viewport>
    </p:group>
    <p:identity name="fileset"/>

</p:declare-step>
