<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" version="1.0">

    <p:declare-step type="px:smil10-join-adjacent">
        <p:output port="result"/>
        <p:input port="source" sequence="true"/>
        <p:wrap-sequence wrapper="smil"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="smil10-join-adjacent.xsl"/>
            </p:input>
        </p:xslt>
    </p:declare-step>
    
    <p:declare-step type="px:smil10-to-smil30">
        <p:option name="language" required="true"/>
        <p:output port="result"/>
        <p:input port="source"/>
        <p:xslt>
            <p:with-param name="language" select="$language"/>
            <p:input port="stylesheet">
                <p:document href="smil10-to-smil30.xsl"/>
            </p:input>
        </p:xslt>
    </p:declare-step>

</p:library>
