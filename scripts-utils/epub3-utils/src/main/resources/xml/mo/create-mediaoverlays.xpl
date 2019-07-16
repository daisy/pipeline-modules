<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                type="px:epub3-create-mediaoverlays" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Create SMIL documents from a set of HTML documents and audio clips.</p>
    </p:documentation>

    <p:input port="content-docs" primary="true" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The HTML documents</p>
        </p:documentation>
    </p:input>
    <p:input port="audio-map">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The d:audio-clips document from the TTS step</p>
        </p:documentation>
    </p:input>
    <p:option name="audio-dir">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Directory for the audio files.</p>
        </p:documentation>
    </p:option>
    <p:option name="mediaoverlay-dir">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Directory for the SMIL files.</p>
        </p:documentation>
    </p:option>

    <p:output port="fileset.out" primary="true"/>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="media-overlays"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:set-base-uri
            px:add-xml-base
        </p:documentation>
    </p:import>

    <p:for-each name="media-overlays">
        <p:output port="result"/>
        <p:variable name="mo-uri"
            select="concat($mediaoverlay-dir,replace(base-uri(/*),'.*?([^/]*)\.x?html$','$1.smil'))"/>
        <p:identity name="content-doc"/>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="result" step="content-doc"/>
                <p:pipe port="audio-map" step="main"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="create-mediaoverlay.xsl"/>
            </p:input>
            <p:with-param name="mo-dir" select="$mediaoverlay-dir"/>
            <p:with-param name="audio-dir" select="$audio-dir"/>
        </p:xslt>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="clean-mediaoverlay.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <px:set-base-uri>
            <p:with-option name="base-uri" select="$mo-uri"/>
        </px:set-base-uri>
        <px:add-xml-base root="false">
            <!--
                otherwise the base URI of some elements would be empty (Calabash bug?)
            -->
        </px:add-xml-base>
    </p:for-each>

    <p:group name="fileset">
        <p:for-each>
            <p:output port="result" sequence="true"/>
            <p:variable name="mo-uri" select="base-uri(/*)"/>
            <px:fileset-create>
                <p:with-option name="base" select="$mediaoverlay-dir"/>
            </px:fileset-create>
            <px:fileset-add-entry media-type="application/smil+xml">
                <p:with-option name="href" select="$mo-uri"/>
            </px:fileset-add-entry>
        </p:for-each>
        <px:fileset-join name="manifest"/>
    </p:group>

</p:declare-step>
