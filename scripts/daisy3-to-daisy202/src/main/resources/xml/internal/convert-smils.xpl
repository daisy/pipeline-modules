<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/daisy3-to-daisy202"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                type="pxi:daisy3-to-daisy202-smils" name="main">

    <p:input port="source.fileset" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Source fileset with DAISY 3 SMIL documents and a NCX document.</p>
        </p:documentation>
    </p:input>
    <p:input port="source.in-memory" sequence="true"/>

    <p:output port="result.fileset" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Result fileset with the DAISY 2.02 SMIL documents and the audio files referenced from
            the SMILs.</p>
        </p:documentation>
    </p:output>
    <p:output port="result.in-memory" sequence="true">
        <p:pipe step="moved-fileset" port="result.in-memory"/>
    </p:output>

    <p:option name="input-dir" required="true"/>
    <p:option name="output-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:assert
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-rebase
            px:fileset-move
            px:fileset-add-entry
            px:fileset-join
            px:fileset-load
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl">
        <p:documentation>
            px:mediatype-detect
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/smil-utils/library.xpl">
        <p:documentation>
            px:smil-to-audio-fileset
        </p:documentation>
    </p:import>

    <px:fileset-load media-types="application/smil+xml" name="input-smils">
        <p:input port="in-memory">
            <p:pipe step="main" port="source.in-memory"/>
        </p:input>
    </px:fileset-load>
    <p:sink/>
    <px:fileset-load media-types="application/x-dtbncx+xml">
        <p:input port="fileset">
            <p:pipe step="main" port="source.fileset"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe step="main" port="source.in-memory"/>
        </p:input>
    </px:fileset-load>
    <px:assert error-code="XXXX" test-count-min="1" test-count-max="1" name="ncx"
               message="The input DTB must contain exactly one NCX file (media-type 'application/x-dtbncx+xml')"/>
    <p:sink/>

    <!--NCX smilCustomTest elements used for SMIL conversion-->
    <p:filter name="custom-tests" select="/ncx:ncx/ncx:head/ncx:smilCustomTest">
        <p:input port="source">
            <p:pipe step="ncx" port="result"/>
        </p:input>
    </p:filter>
    <p:sink/>
    <!--NCX references to SMIL docs, grouped by doc URIs.-->
    <p:xslt name="ncx-idrefs">
        <p:input port="source">
            <p:pipe step="ncx" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncx-to-smil-id-map.xsl"/>
        </p:input>
        <p:input port="parameters">
            <!--FIXME pass the relative URI to the NCC-->
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:sink/>

    <!--Main iteration over input SMIL docs-->
    <p:for-each name="iter-smils">
        <p:iteration-source>
            <p:pipe step="input-smils" port="result"/>
        </p:iteration-source>
        <p:output port="audio.fileset" primary="true"/>
        <p:output port="smil.in-memory">
            <p:pipe step="smil-to-smil" port="result"/>
        </p:output>

        <!--Get the list of NCX ID references to this SMIL-->
        <p:filter name="idrefs">
            <p:input port="source">
                <p:pipe port="result" step="ncx-idrefs"/>
            </p:input>
            <p:with-option name="select" select="concat('/*/d:doc[@href=''',base-uri(/),''']')">
                <p:pipe step="iter-smils" port="current"/>
            </p:with-option>
        </p:filter>

        <!--Convert DAISY 2.02 SMIL to DAISY 3 SMIL-->
        <p:xslt name="smil-to-smil">
            <p:input port="source">
                <p:pipe port="current" step="iter-smils"/>
                <p:pipe port="result" step="custom-tests"/>
                <p:pipe port="result" step="idrefs"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="smil-to-smil.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:sink/>

        <!--Fileset of the audio files used in this SMIL-->
        <px:smil-to-audio-fileset>
            <p:input port="source">
                <p:pipe port="result" step="smil-to-smil"/>
            </p:input>
        </px:smil-to-audio-fileset>
        <px:mediatype-detect/>
    </p:for-each>
    <px:fileset-join name="audio-fileset"/>
    <p:sink/>
    <p:add-attribute match="/d:file" attribute-name="media-type" attribute-value="application/smil+xml" name="smil-fileset">
        <p:input port="source">
            <p:pipe step="input-smils" port="result.fileset"/>
        </p:input>
    </p:add-attribute>
    <p:sink/>
    <px:fileset-join>
        <p:input port="source">
            <p:pipe step="smil-fileset" port="result"/>
            <p:pipe step="audio-fileset" port="result"/>
        </p:input>
    </px:fileset-join>
    <px:fileset-rebase>
        <p:with-option name="new-base" select="$input-dir"/>
    </px:fileset-rebase>
    <px:fileset-move name="moved-fileset">
        <p:input port="source.in-memory">
            <p:pipe step="iter-smils" port="smil.in-memory"/>
        </p:input>
        <p:with-option name="target" select="$output-dir"></p:with-option>
    </px:fileset-move>

</p:declare-step>
