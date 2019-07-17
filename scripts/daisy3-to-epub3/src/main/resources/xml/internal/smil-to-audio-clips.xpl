<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/daisy3-to-epub3"
                type="pxi:smil-to-audio-clips" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Create a d:audio-clips document from a set of SMIL and content documents.</p>
    </p:documentation>

    <p:input port="smils" sequence="true" primary="true"/>
    <p:input port="dtbooks" sequence="true"/>

    <p:output port="result">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The d:audio-clips document</p>
        </p:documentation>
    </p:output>

    <p:option name="output-base-uri" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The base URI of the d:audio-clips document</p>
        </p:documentation>
    </p:option>

    <p:xslt template-name="create-map">
        <p:input port="source">
            <p:pipe step="main" port="dtbooks"/>
            <p:pipe step="main" port="smils"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="smil-to-audio-clips.xsl"/>
        </p:input>
        <p:with-param name="output-base-uri" select="$output-base-uri"/>
        <p:with-option name="output-base-uri" select="$output-base-uri"/>
    </p:xslt>

</p:declare-step>
