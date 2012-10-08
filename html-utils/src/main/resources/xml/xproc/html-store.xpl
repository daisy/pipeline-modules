<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    type="px:html-store" name="main" exclude-inline-prefixes="#all"
    version="1.0">

    <p:documentation>
        Packages and stores an HTML fileset to disk.
    </p:documentation>

    <p:input port="fileset.in" primary="true">
        <p:documentation>
            A fileset referencing all resources to be stored. Contains references to the HTML file and any resources it references (images etc.).
        </p:documentation>
    </p:input>

    <p:input port="in-memory.in" sequence="true">
        <p:documentation>In-memory documents (XHTML).</p:documentation>
    </p:input>

    <p:option name="html-file" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl">
        <p:documentation>For manipulating filesets.</p:documentation>
    </p:import>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl">
        <p:documentation>For manipulating files.</p:documentation>
    </p:import>

    <p:variable name="fileset-base" select="base-uri(/*)"/>

    <cx:message message="Storing HTML fileset."/>
    <p:sink/>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="in-memory.in" step="main"/>
        </p:iteration-source>
        <p:add-attribute attribute-name="href" match="/*">
            <p:input port="source">
                <p:inline>
                    <d:file/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="resolve-uri(base-uri(/*))"/>
        </p:add-attribute>
    </p:for-each>
    <p:wrap-sequence wrapper="d:fileset"/>
    <px:fileset-join name="fileset.in-memory"/>


    <p:documentation>Store files and filters out missing files in the result fileset.</p:documentation>
    <p:viewport match="d:file" name="store">
        <p:output port="result"/>
        <p:viewport-source>
            <p:pipe port="fileset.in" step="main"/>
        </p:viewport-source>
        <p:variable name="on-disk" select="(/*/@original-href, '')[1]"/>
        <p:variable name="target" select="resolve-uri(/*/@href, $fileset-base)"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="fileset.in-memory"/>
            </p:xpath-context>
            <p:when test="//d:file[@href=$target]">
                <p:documentation>File is in memory.</p:documentation>
                <cx:message>
                    <p:with-option name="message" select="concat('Writing in-memory document to ',$target)"
                    />
                </cx:message>
                <p:split-sequence>
                    <p:with-option name="test"
                        select="concat('base-uri(/*)=&quot;',$target,'&quot;')"/>
                    <p:input port="source">
                        <p:pipe port="in-memory.in" step="main"/>
                    </p:input>
                </p:split-sequence>
                <p:delete match="/*/@xml:base"/>
                <p:choose>
                    <p:when test="$media-type='application/xhtml+xml'">
                        <p:documentation>In-memory file is a Content Document.</p:documentation>
                        <p:store indent="true" encoding="utf-8" method="xhtml"
                            include-content-type="false" name="store.content-doc">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                    </p:when>
                    <p:otherwise>
                        <p:documentation>In-memory file stored as-is.</p:documentation>
                        <p:store name="store.as-is">
                            <p:with-option name="href" select="$target"/>
                        </p:store>
                    </p:otherwise>
                </p:choose>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="current" step="store"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:when test="not($on-disk)">
                <p:error code="PEZE00">
                    <p:input port="source">
                        <p:inline>
                            <c:message>Found document in fileset that are neither stored on disk nor
                                in memory.</c:message>
                        </p:inline>
                    </p:input>
                </p:error>
            </p:when>
            <p:otherwise>
                <p:documentation>File is already on disk; copy it to the new
                    location.</p:documentation>
                <p:variable name="target-dir" select="replace($target,'[^/]+$','')"/>
                <cx:message>
                    <p:with-option name="message" select="concat('Copying disk file to ',$target)"/>
                </cx:message>
                <p:try>
                    <p:group>
                        <px:info>
                            <p:with-option name="href" select="$target-dir"/>
                        </px:info>
                    </p:group>
                    <p:catch>
                        <p:identity>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                        </p:identity>
                    </p:catch>
                </p:try>
                <p:wrap-sequence wrapper="info"/>
                <p:choose name="mkdir">
                    <p:when test="empty(/info/*)">
                        <px:mkdir>
                            <p:with-option name="href" select="$target-dir"/>
                        </px:mkdir>
                    </p:when>
                    <p:when test="not(/info/c:directory)">
                        <!--TODO rename the error-->
                        <p:error code="err:file">
                            <p:input port="source">
                                <p:inline exclude-inline-prefixes="d">
                                    <c:message>The target is not a directory.</c:message>
                                </p:inline>
                            </p:input>
                        </p:error>
                        <p:sink/>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                        <p:sink/>
                    </p:otherwise>
                </p:choose>
                <p:try  cx:depends-on="mkdir" name="store.copy">
                    <p:group>
                        <p:output port="result"/>
                        <px:copy name="store.copy.do">
                            <p:with-option name="href" select="$on-disk"/>
                            <p:with-option name="target" select="$target"/>
                        </px:copy>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="current" step="store"/>
                            </p:input>
                        </p:identity>
                    </p:group>
                    <p:catch name="store.copy.catch">
                        <p:output port="result"/>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="error" step="store.copy.catch"/>
                            </p:input>
                        </p:identity>
                        <cx:message>
                            <p:with-option name="message" select="concat('Copy error: ',/*/*)"/>
                        </cx:message>
                        <p:identity>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                        </p:identity>
                    </p:catch>
                </p:try>
            </p:otherwise>
        </p:choose>
    </p:viewport>
    <p:sink/>

</p:declare-step>
