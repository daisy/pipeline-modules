<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
    type="px:epub3-pub-create-package-doc" name="main"
    xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    version="1.0">

    <p:input port="fileset" primary="true"/>
    <p:input port="spine"/>
    <p:input port="metadata"/>
    <p:output port="result"/>

    <p:group name="create-metadata">
        <!--TODO what format is the input metadata ?-->
        <p:identity>
            <p:input port="source">
                <p:pipe port="metadata" step="main"/>
            </p:input>
        </p:identity>
    </p:group>
    <p:group name="create-manifest">
        <!--TODO make sure file set entries have a @media-type-->
        <!--TODO handle fallbacks-->
        <!--TODO identify properties: cover-image, mathml, nav, remote-resources, scripted, svg, switch-->
        <p:xslt>
            <p:input port="source">
                <p:pipe port="filest" step="main"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/fileset-to-manifest.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:group>
    <p:group name="create-spine">
        <p:wrap-sequence wrapper="wrapper">
            <p:input port="source">
                <p:pipe port="spine" step="main"/>
                <p:pipe port="result" step="create-manifest"/>
            </p:input>
        </p:wrap-sequence>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/fileset-to-spine.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:group>

    <p:identity>
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <package xmlns="http://www.idpf.org/2007/opf" version="3.0"
                    profile="http://www.idpf.org/epub/30/profile/package/"/>
            </p:inline>
        </p:input>
    </p:identity>
    <p:insert position="last-child">
        <p:input port="insertion">
            <p:pipe port="result" step="create-metadata"/>
            <p:pipe port="result" step="create-manifest"/>
            <p:pipe port="result" step="create-spine"/>
        </p:input>
    </p:insert>
    <p:add-attribute attribute-name="unique-identifier" match="/*" attribute-value="pub-id"/>
    <p:add-attribute attribute-name="xml:lang" match="/*">
        <p:with-option name="attribute-value"
            select="/opf:package/opf:metadata/opf:meta[@property='dcterms:language']"/>
    </p:add-attribute>

</p:declare-step>
