<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:dtbook-load" name="main">

    <p:documentation> Loads the DTBook XML fileset. </p:documentation>

    <p:input port="source" primary="true" sequence="true" px:media-type="application/x-dtbook+xml">
        <p:documentation> One or more DTBook files to be loaded. Any auxilliary resources referenced
            from the DTBook documents will be resolved based on these files. </p:documentation>
    </p:input>

    <p:output port="fileset.out" primary="true">
        <p:documentation> A fileset containing references to all the DTBook files and any resources
            they reference (images etc.). The xml:base is also set with an absolute URI for each
            file, and is intended to represent the "original file", while the href can change during
            conversions to reflect the path and filename of the resource in the output fileset.
        </p:documentation>
    </p:output>

    <p:output port="in-memory.out" sequence="true">
        <p:documentation> A sequence of all the DTBook documents loaded from disk so that the DTBook
            conversion step does not depend on documents being stored on disk. This means that the
            conversion step can receive DTBook documents either through this step, or as a result
            from other conversion steps, allowing for easy chaining of scripts.
        </p:documentation>
        <p:pipe port="result" step="dtbook"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:message
            px:parse-xml-stylesheet-instructions
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-join
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl">
        <p:documentation>
            px:mediatype-detect
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/css-utils/library.xpl">
        <p:documentation>
            px:css-to-fileset
        </p:documentation>
    </p:import>

    <p:identity name="dtbook"/>
    
    <p:for-each>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="dtbook-fileset.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <px:fileset-join/>
    <px:mediatype-detect/>
    <p:identity name="dtbook-resources-mathml"/>
    <p:sink/>
    
    <!-- add any CSS stylesheets from xml-stylesheet instructions  -->
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="main" port="source"/>
        </p:iteration-source>
        <px:parse-xml-stylesheet-instructions name="parse-pi"/>
        <p:sink/>
        <p:delete match="d:file[not(@media-type='text/css')]">
            <p:input port="source">
                <p:pipe step="parse-pi" port="fileset"/>
            </p:input>
        </p:delete>
    </p:for-each>
    <p:identity name="css-from-pi"/>
    <p:sink/>

    <p:group name="referenced-from-css">
        <p:output port="result"/>
        <px:fileset-join>
            <p:input port="source">
                <p:pipe step="dtbook-resources-mathml" port="result"/>
                <p:pipe step="css-from-pi" port="result"/>
            </p:input>
        </px:fileset-join>
        <px:css-to-fileset/>
    </p:group>
    <p:sink/>

    <px:fileset-join>
        <p:input port="source">
            <p:pipe step="dtbook-resources-mathml" port="result"/>
            <p:pipe step="css-from-pi" port="result"/>
            <p:pipe step="referenced-from-css" port="result"/>
        </p:input>
    </px:fileset-join>
    
</p:declare-step>
