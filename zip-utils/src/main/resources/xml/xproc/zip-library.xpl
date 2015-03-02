<p:library version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc">

    <p:declare-step type="px:zip-manifest-from-fileset">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/fileset-to-zip-manifest.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:declare-step>
    
    <p:import href="java-library.xpl"/>
    <p:import href="unzip-fileset.xpl"/>
    
</p:library>
