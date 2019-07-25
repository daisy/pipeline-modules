<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                type="px:epub3-safe-uris" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Change all URIs in a fileset to EPUB-safe URIs.</p>
    </p:documentation>

    <p:input port="source.fileset" primary="true"/>
    <p:input port="source.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The input fileset</p>
        </p:documentation>
        <p:empty/>
    </p:input>

    <p:output port="result.fileset" primary="true">
        <p:pipe step="fileset" port="result"/>
    </p:output>
    <p:output port="result.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The output fileset</p>
            <p>The xml:base, href and original-href attributes in the fileset manifest or changed to
            EPUB-safe URIs. The base URIs of the in-memory documents are updated accordingly.</p>
        </p:documentation>
        <p:pipe step="in-memory" port="result"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:set-base-uri
            px:normalize-uri
        </p:documentation>
    </p:import>

    <p:add-xml-base/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="epub3-safe-uris.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    <p:identity name="fileset-with-href-before-move"/>
    <p:delete match="/*/*/@href-before-move"/>
    <p:identity name="fileset"/>

    <p:documentation>Update the base URI of the in-memory documents</p:documentation>
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="main" port="source.in-memory"/>
        </p:iteration-source>
        <px:normalize-uri name="normalize-uri">
            <p:with-option name="href" select="base-uri(/*)"/>
        </px:normalize-uri>
        <p:group>
            <p:variable name="base-uri" select="string(/*)">
                <p:pipe step="normalize-uri" port="normalized"/>
            </p:variable>
            <p:choose>
                <p:xpath-context>
                    <p:pipe step="fileset-with-href-before-move" port="result"/>
                </p:xpath-context>
                <p:when test="$base-uri=/*/d:file/@href-before-move">
                    <px:set-base-uri>
                        <p:with-option name="base-uri" select="(/*/d:file[@href-before-move=$base-uri])[1]/resolve-uri(@href,base-uri(.))">
                            <p:pipe step="fileset-with-href-before-move" port="result"/>
                        </p:with-option>
                    </px:set-base-uri>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:group>
    </p:for-each>
    <p:identity name="in-memory"/>

</p:declare-step>
