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
        <p:pipe step="updated-references" port="result.fileset"/>
    </p:output>
    <p:output port="result.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The output fileset</p>
            <p>The xml:base, href and original-href attributes in the fileset manifest or changed to
            EPUB-safe URIs. The base URIs of the in-memory documents are updated
            accordingly. Cross-references in HTML documents are updated too.</p>
        </p:documentation>
        <p:pipe step="updated-references" port="result.in-memory"/>
    </p:output>
    <p:output port="mapping">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>A <code>d:fileset</code> document that contains the mapping from the source files
            (<code>@original-href</code>) to the copied files (<code>@href</code>).</p>
        </p:documentation>
        <p:pipe step="mapping" port="result"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:set-base-uri
            px:normalize-uri
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-filter
            px:fileset-load
            px:fileset-update
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/library.xpl">
        <p:documentation>
            px:html-update-links
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
    <p:label-elements match="d:file[@href=preceding-sibling::d:file/@href]" attribute="href" replace="true"
                      label="for $href in @href
                             return replace($href,
                                            '^(.+?)(\.[^\.]+)?$',
                                            concat('$1_',1+count(preceding-sibling::d:file[@href=$href]),'$2'))">
        <p:documentation>Because the renaming may have resulted in duplicate file names</p:documentation>
    </p:label-elements>
    <p:identity name="fileset-with-href-before-move"/>
    <p:delete match="/*/*/@href-before-move"/>
    <p:identity name="fileset"/>
    <p:sink/>

    <p:label-elements match="d:file" attribute="original-href" label="@href-before-move" replace="true">
        <p:input port="source">
            <p:pipe step="fileset-with-href-before-move" port="result"/>
        </p:input>
    </p:label-elements>
    <p:delete match="/*/*[not(self::d:file)]"/>
    <p:delete match="d:file/@*[not(name()=('href','original-href'))]" name="mapping"/>
    <p:sink/>

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
    <p:sink/>

    <p:documentation>Update cross-references in HTML documents</p:documentation>
    <px:fileset-load media-types="application/xhtml+xml" name="html">
        <p:input port="fileset">
            <p:pipe step="fileset" port="result"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe step="in-memory" port="result"/>
        </p:input>
    </px:fileset-load>
    <p:for-each name="updated-html">
        <p:output port="result"/>
        <px:html-update-links>
            <p:input port="mapping">
                <p:pipe step="mapping" port="result"/>
            </p:input>
        </px:html-update-links>
    </p:for-each>
    <p:sink/>
    <px:fileset-update name="updated-references">
        <p:input port="source.fileset">
            <p:pipe step="fileset" port="result"/>
        </p:input>
        <p:input port="source.in-memory">
            <p:pipe step="in-memory" port="result"/>
        </p:input>
        <p:input port="update.fileset">
            <p:pipe step="html" port="result.fileset"/>
        </p:input>
        <p:input port="update.in-memory">
            <p:pipe step="updated-html" port="result"/>
        </p:input>
    </px:fileset-update>
    <p:sink/>

</p:declare-step>
