<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:diagram-to-html" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Converts any DIAGRAM descriptions in the input fileset into HTML.</p>
    </p:documentation>

    <p:input port="source.fileset" primary="true"/>
    <p:input port="source.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Input fileset</p>
        </p:documentation>
        <p:empty/>
    </p:input>

    <p:output port="result.fileset" primary="true"/>
    <p:output port="result.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>A fileset where old DIAGRAM entries have been replaced by entries representing the
            newly produced HTML documents.</p>
            <p>The HTML documents have the same location of the DIAGRAM files and have the file
            extension ".xhtml".</p>
        </p:documentation>
        <p:pipe step="update" port="result.in-memory"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
            px:fileset-update
        </p:documentation>
    </p:import>

    <p:delete match="d:file[not(tokenize(@kind,'\s+') = 'description')]"/>
    <px:fileset-load name="descriptions" media-types="application/xml application/z3998-auth-diagram+xml">
        <p:input port="in-memory">
            <p:pipe step="main" port="source.in-memory"/>
        </p:input>
    </px:fileset-load>
    <p:sink/>

    <p:xslt name="convert" initial-mode="fileset">
        <p:input port="source">
            <p:pipe step="main" port="source.fileset"/>
            <p:pipe step="descriptions" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/fileset-convert-diagram.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <px:fileset-update name="update">
        <p:input port="source.in-memory">
            <p:pipe step="main" port="source.in-memory"/>
            <p:pipe step="convert" port="secondary"/>
        </p:input>
        <p:input port="update.fileset">
            <p:inline><d:fileset/></p:inline>
        </p:input>
        <p:input port="update.in-memory">
            <!-- update empty because only calling px:fileset-update for purging in-memory port -->
            <p:empty/>
        </p:input>
    </px:fileset-update>

</p:declare-step>
