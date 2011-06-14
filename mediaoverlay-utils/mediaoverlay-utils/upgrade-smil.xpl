<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" type="px:mediatype-upgrade-smil" version="1.0">

    <p:option name="language" required="true"/>
    <p:output port="result"/>
    <p:input port="source"/>
    
    <p:choose>
        <p:when test="not(local-name(/*)='smil')">
            <!-- Not a SMIL-file -->
            <p:identity/>
            <!--p:error/-->
        </p:when>
        <p:when test="/*/@profile='http://www.idpf.org/epub/30/profile/content/'">
            <!-- EPUB3 Media Overlay -->
            <!-- validate SMIL 3.0 here -->
            <p:identity/>
        </p:when>
        <p:when test="namespace-uri(/*)='http://www.w3.org/2001/SMIL20/'">
            <!-- DTBook -->
            <!-- validate SMIL 2.0 here (dtbsmil-2005-2.dtd) -->
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="upgrade-smil-dtbook.xsl"/>
                </p:input>
            </p:xslt>
        </p:when>
        <p:when test="local-name(/*)='smil'">
            <!-- DAISY 2.02 -->
            <!-- validate SMIL 1.0 here (SMIL10.dtd) -->
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="upgrade-smil-daisy202.xsl"/>
                </p:input>
            </p:xslt>
        </p:when>
    </p:choose>

</p:declare-step>
