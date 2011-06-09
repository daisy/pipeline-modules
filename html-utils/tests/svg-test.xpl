<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

    <p:output port="result"/>

    <p:import href="../html-library.xpl"/>

    <px:html-load>
        <p:with-option name="href" select="p:resolve-uri('svg-test.html',p:resolve-uri(/*))">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </px:html-load>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:attribute name="ns" select="namespace-uri()"/>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

</p:declare-step>
