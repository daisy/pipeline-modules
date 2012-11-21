<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pf="http://www.daisy.org/ns/pipeline/functions" xmlns="http://www.w3.org/1999/xhtml" xmlns:utfx="http://utfx.org/test-definition"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs" version="2.0">

    <xsl:import href="../../main/resources/xml/xslt/uri-functions.xsl"/>
    <xsl:variable name="uri" select="'../../main/resources/xml/xslt/uri-functions.xsl'"/>

    <xsl:output method="xhtml" indent="yes"/>

    <xsl:template match="/*">
        <html>
            <head>
                <title>
                    <xsl:value-of select="replace(base-uri(.),'^.*/([^/]*)$','$1')"/>
                </title>
                <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/css/bootstrap-combined.min.css" rel="stylesheet"/>
                <script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/js/bootstrap.min.js"><![CDATA[]]></script>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="replace(base-uri(.),'^.*/([^/]*)$','$1')"/>
                </h1>
                <xsl:for-each select="utfx:test">
                    <section>
                        <h2>
                            <xsl:value-of select="utfx:name"/>
                        </h2>
                        <xsl:variable name="test-result">
                            <xsl:for-each select=".//*[local-name()='test']">
                                <xsl:sequence
                                    select="@expected=(
                                    if (@function='tokenize-uri') then pf:tokenize-uri(@uri) else
                                    if (@function='recompose-uri') then pf:recompose-uri(@tokens) else
                                    if (@function='normalize-uri') then pf:normalize-uri(@uri) else
                                    if (@function='relativize-uri') then pf:relativize-uri(@uri, @base) else
                                    if (@function='normalize-path') then pf:normalize-path(@path) else
                                    if (@function='relativize-path') then pf:relativize-path(@path, @base) else
                                    if (@function='longest-common-uri') then pf:longest-common-uri(tokenize(@uris,' ')) else
                                    '')"
                                />
                            </xsl:for-each>
                        </xsl:variable>
                        <p>Test result: <xsl:value-of select="if (matches($test-result,'false')) then 'FAILED' else 'SUCCESS'"/></p>
                        <table style="text-align:left;width:100%;" class="table">
                            <tr>
                                <th>Parameters</th>
                                <th>Expected</th>
                                <th>Actual</th>
                                <th>Result</th>
                            </tr>
                            <xsl:for-each select=".//*[local-name()='test']">
                                <tr>
                                    <th>
                                        <xsl:for-each select="@*[not(name()=('function','expected'))]">
                                            <xsl:if test="position()&gt;1">
                                                <br/>
                                            </xsl:if>
                                            <span>
                                                <xsl:value-of select="concat(local-name(),': &quot;',.,'&quot;')"/>
                                            </span>
                                        </xsl:for-each>
                                    </th>
                                    <th>
                                        <xsl:value-of select="@expected"/>
                                    </th>
                                    <xsl:variable name="actual"
                                        select="
                                        if (@function='tokenize-uri') then pf:tokenize-uri(@uri) else
                                        if (@function='recompose-uri') then pf:recompose-uri(@tokens) else
                                        if (@function='normalize-uri') then pf:normalize-uri(@uri) else
                                        if (@function='relativize-uri') then pf:relativize-uri(@uri, @base) else
                                        if (@function='normalize-path') then pf:normalize-path(@path) else
                                        if (@function='relativize-path') then pf:relativize-path(@path, @base) else
                                        if (@function='longest-common-uri') then pf:longest-common-uri(tokenize(@uris,' ')) else
                                        ''"/>
                                    <th>
                                        <xsl:value-of select="$actual"/>
                                    </th>
                                    <th>
                                        <xsl:value-of select="if (@expected=$actual) then 'SUCCESS' else 'FAILED'"/>
                                    </th>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </section>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
