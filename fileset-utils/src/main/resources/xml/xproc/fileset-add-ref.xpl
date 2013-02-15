<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-add-ref" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="cx px">

    <p:input port="source"/>
    <p:output port="result"/>

    <p:option name="href" required="true"/>
    <p:option name="ref" select="''"><!-- if relative; will be resolved relative to the file --></p:option>
    <p:option name="first" select="'false'"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!--TODO awkward, add the entry with XProc, then perform URI cleanup-->
    <p:add-xml-base all="true" relative="false"/>
    <p:xslt name="href-uri">
        <p:with-param name="href" select="$href"/>
        <p:with-param name="ref" select="$ref"/>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" version="2.0" exclude-result-prefixes="#all">
                    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
                    <xsl:param name="href" required="yes"/>
                    <xsl:param name="ref" required="yes"/>
                    <xsl:template match="/*">
                        <d:ref>
                            <xsl:for-each select="d:file[pf:normalize-uri(resolve-uri(@href,@xml:base)) = pf:normalize-uri(resolve-uri($href,@xml:base))][1]">
                                <xsl:attribute name="href" select="pf:normalize-uri(resolve-uri($ref,resolve-uri(@href,@xml:base)))"/>
                                <xsl:attribute name="parent-href" select="@href"/>
                            </xsl:for-each>
                        </d:ref>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

    <p:choose>
        <p:when test="not(/*/@href)">
            <p:identity>
                <p:input port="source">
                    <p:pipe port="source" step="main"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:variable name="href-uri-ified" select="/*/@href">
                <p:pipe port="result" step="href-uri"/>
            </p:variable>
            <p:variable name="file-href" select="/*/@parent-href">
                <p:pipe port="result" step="href-uri"/>
            </p:variable>

            <p:delete match="//@parent-href"/>

            <!--Insert the entry as the last or first child of the file set-->
            <p:insert>
                <p:with-option name="match" select="concat(&quot;//d:file[@href='&quot;,$file-href,&quot;']&quot;)"/>
                <p:with-option name="position" select="if ($first='true') then 'first-child' else 'last-child'"/>
                <p:input port="source">
                    <p:pipe port="source" step="main"/>
                </p:input>
            </p:insert>
        </p:otherwise>
    </p:choose>

</p:declare-step>
