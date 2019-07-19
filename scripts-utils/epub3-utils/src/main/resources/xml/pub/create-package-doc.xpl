<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                type="px:epub3-pub-create-package-doc" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Create a <a href="http://www.idpf.org/epub/301/spec/epub-publications.html">EPUB Package
        Document</a></p>
    </p:documentation>

    <p:input port="source.fileset" primary="true"/>
    <p:input port="source.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Files to be included in the publication: <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#gloss-content-document-epub">content
            documents</a>, <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#gloss-media-overlay-document">media
            overlay documents</a> and other resources.</p>
        </p:documentation>
    </p:input>

    <p:input port="spine" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Fileset that will make up the primary <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#sec-spine-elem">spine</a>
            items.</p>
            <p>If not specified, defaults to all <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#gloss-content-document-epub">content
            documents</a>, in the order in which they are specified in "source.fileset".</p>
            <p>The content documents in "source.fileset" that are not in "spine" become auxiliary
            spine items.</p>
        </p:documentation>
        <p:empty/>
    </p:input>
    <p:input port="metadata" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Sequence of <code>metadata</code> elements in the OPF namespace from which the <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#sec-metadata-elem"><code>metadata</code>
            element</a> for the package document will be constructed.</p>
            <p>Will be augmented with "duration" metadata that is extracted from the media overlay
            documents.</p>
            <p>If not specified, a metadata element with the minimal required metadata will be
            included.</p>
        </p:documentation>
        <p:inline>
            <opf:metadata/>
        </p:inline>
    </p:input>
    <p:input port="bindings" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Fileset from which to contruct the <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#sec-bindings-elem"><code>bindings</code></a>
            element of the package document.</p>
            <p>Ignored if compatibility-mode is not true.</p>
        </p:documentation>
        <p:empty/>
    </p:input>
    <p:option name="nav-uri" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>URI of the file that is to be used as the navigation document.</p>
            <p>Must be a content document.</p>
            <p>If not specified, the content document that contains a
            <code>nav[@epub:type='toc']</code> element is picked.</p>
        </p:documentation>
    </p:option>
    <p:option name="cover-image" required="false" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>URI of the file that is to be marked as the <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#cover-image"><code>cover-image</code></a>.</p>
        </p:documentation>
    </p:option>
    <p:option name="compatibility-mode" required="false" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Whether to be backward compatible with <a
            href="http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm">Open Package Format
            2.0.1</a>.</p>
        </p:documentation>
    </p:option>
    <p:option name="detect-properties" required="false" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Whether to automatically detect <a
            href="http://www.idpf.org/epub/301/spec/epub-publications.html#sec-item-property-values">manifest
            item properties</a>:</p>
            <ul>
                <ol><a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#mathml"><code>mathml</code></a>:
                when a document contains instances of MathML markup</ol>
                <ol><a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#remote-resources"><code>remote-resources</code></a>:
                when a document contains references to other publication resources that are <a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#sec-resource-locations">located
                outside of the EPUB container</a></ol>
                <ol><a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#scripted"><code>scripted</code></a>:
                when a document is a <a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#gloss-content-document-epub-scripted">scripted
                content document</a> (contains scripted content and/or elements from HTML5 forms)</ol>
                <ol><a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#svg"><code>svg</code></a>:
                when a document is a <a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#gloss-content-document-epub-svg">SVG
                content document</a> or contains instances of SVG markup</ol>
                <ol><a
                href="http://www.idpf.org/epub/301/spec/epub-publications.html#switch"><code>switch</code></a>:
                when a document contains <a
                href="http://www.idpf.org/epub/301/spec/epub-contentdocs.html#elemdef-switch"><code>epub:switch</code></a>
                elements</ol>
            </ul>
        </p:documentation>
    </p:option>
    <p:option name="output-base-uri" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The base URI of the result document.</p>
        </p:documentation>
    </p:option>
    <p:output port="result" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The package document.</p>
        </p:documentation>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:set-base-uri
            px:add-xml-base
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
            px:fileset-filter
            px:fileset-join
            px:fileset-intersect
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl">
        <p:documentation>
            px:mediatype-detect
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:assert
            px:message
        </p:documentation>
    </p:import>
    <p:import href="../nav/epub3-nav-to-guide.xpl">
        <p:documentation>
            px:epub3-nav-to-guide
        </p:documentation>
    </p:import>

    <px:mediatype-detect name="source.fileset">
        <p:input port="in-memory">
            <p:pipe step="main" port="source.in-memory"/>
        </p:input>
    </px:mediatype-detect>

    <p:documentation>Get content documents</p:documentation>
    <p:group name="content-docs">
        <p:output port="fileset" primary="true">
            <p:pipe step="fileset" port="result"/>
        </p:output>
        <p:output port="in-memory" sequence="true">
            <p:pipe step="in-memory" port="result"/>
        </p:output>
        <px:fileset-filter media-types="application/xhtml+xml image/svg+xml" name="fileset"/>
        <px:fileset-load name="in-memory">
            <p:input port="in-memory">
                <p:pipe step="main" port="source.in-memory"/>
            </p:input>
        </px:fileset-load>
    </p:group>
    <p:sink/>

    <p:documentation>Get navigation document</p:documentation>
    <p:group name="nav-doc">
        <p:output port="result"/>
        <p:choose>
            <p:when test="not($nav-uri='')">
                <px:fileset-load>
                    <p:input port="fileset">
                        <p:pipe step="content-docs" port="fileset"/>
                    </p:input>
                    <p:input port="in-memory">
                        <p:pipe step="content-docs" port="in-memory"/>
                    </p:input>
                    <p:with-option name="href" select="resolve-uri($nav-uri,base-uri(/*))">
                        <p:pipe step="main" port="source.fileset"/>
                    </p:with-option>
                </px:fileset-load>
            </p:when>
            <p:otherwise>
                <p:split-sequence test="//html:nav[@epub:type='toc']">
                    <p:input port="source">
                        <p:pipe step="content-docs" port="in-memory"/>
                    </p:input>
                </p:split-sequence>
            </p:otherwise>
        </p:choose>
        <px:assert message="There must be exactly one navigation document in the fileset" test-count-min="1" test-count-max="1" error-code="PEPU14"/>
        <px:message severity="DEBUG" message="Navigation document extracted from fileset"/>
    </p:group>
    <p:sink/>

    <p:documentation>Get media overlay documents</p:documentation>
    <p:group name="mediaoverlays">
        <p:output port="fileset" primary="true">
            <p:pipe step="fileset" port="result"/>
        </p:output>
        <p:output port="in-memory" sequence="true">
            <p:pipe step="in-memory" port="result"/>
        </p:output>
        <px:fileset-filter media-types="application/smil+xml" name="fileset">
            <p:input port="source">
                <p:pipe step="main" port="source.fileset"/>
            </p:input>
        </px:fileset-filter>
        <px:fileset-load name="in-memory">
            <p:input port="in-memory">
                <p:pipe step="main" port="source.in-memory"/>
            </p:input>
        </px:fileset-load>
    </p:group>
    <p:sink/>

    <p:documentation>Construct metadata element</p:documentation>
    <p:group name="metadata">
        <p:output port="result"/>
        <p:uuid name="default-metadata" match="dc:identifier/text()">
            <p:documentation>Minimal required metadata</p:documentation>
            <p:input port="source">
                <p:inline>
                    <opf:metadata>
                        <dc:title>Unknown</dc:title>
                        <dc:identifier>generated-uuid</dc:identifier>
                    </opf:metadata>
                </p:inline>
            </p:input>
        </p:uuid>
        <p:wrap-sequence wrapper="_">
            <p:input port="source">
                <p:pipe step="main" port="metadata"/>
                <p:pipe step="default-metadata" port="result"/>
            </p:input>
        </p:wrap-sequence>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="create-metadata.merge.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <p:documentation>Extract "duration" metadata from media overlay documents.</p:documentation>
        <p:delete match="opf:meta[@property='media:duration']"/>
        <p:identity name="metadata.without-duration"/>
        <p:sink/>
        <p:for-each name="metadata.durations">
            <p:output port="result" sequence="true"/>
            <p:iteration-source>
                <p:pipe step="mediaoverlays" port="in-memory"/>
            </p:iteration-source>
            <p:variable name="base" select="base-uri(/*)"/>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="create-package-doc.estimate-mediaoverlay-duration.xsl"/>
                </p:input>
            </p:xslt>
            <p:add-attribute match="/*" attribute-name="refines">
                <p:with-option name="attribute-value"
                               select="concat('#',/*/d:file[resolve-uri(@href,base-uri(.))=$base]/@id)">
                    <p:pipe step="manifest" port="as-fileset"/>
                </p:with-option>
            </p:add-attribute>
        </p:for-each>
        <p:sink/>
        <p:group name="metadata.total-duration">
            <p:output port="result" sequence="true"/>
            <p:count>
                <p:input port="source">
                    <p:pipe step="metadata.durations" port="result"/>
                </p:input>
            </p:count>
            <p:choose>
                <p:when test="/*=0">
                    <p:identity>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <p:wrap-sequence wrapper="_">
                        <p:input port="source">
                            <p:pipe step="metadata.durations" port="result"/>
                        </p:input>
                    </p:wrap-sequence>
                    <p:xslt>
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="create-package-doc.sum-mediaoverlay-durations.xsl"/>
                        </p:input>
                    </p:xslt>
                </p:otherwise>
            </p:choose>
        </p:group>
        <p:sink/>
        <p:insert match="/*" position="last-child">
            <p:input port="source">
                <p:pipe step="metadata.without-duration" port="result"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe step="metadata.durations" port="result"/>
                <p:pipe step="metadata.total-duration" port="result"/>
            </p:input>
        </p:insert>

        <p:documentation>For compatibility with OPF 2, add a second meta element with "name" and
        "content" attributes for every meta element.</p:documentation>
        <p:choose>
            <p:when test="$compatibility-mode='true'">
                <p:xslt>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="create-package-doc.backwards-compatible-metadata.xsl"/>
                    </p:input>
                </p:xslt>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <px:message severity="DEBUG" message="Successfully created package document metadata"/>
    </p:group>
    <p:sink/>

    <p:documentation>Get primary spine items</p:documentation>
    <p:group name="spine.primary">
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:pipe step="main" port="spine"/>
            </p:input>
        </p:identity>
        <px:assert message="There can be at most one document on the 'spine' port" test-count-min="0" test-count-max="1" error-code="XXXX"/>
        <p:count/>
        <p:choose>
            <p:when test="/*=1">
                <px:fileset-intersect>
                    <p:input port="source">
                        <p:pipe step="content-docs" port="fileset"/>
                        <p:pipe step="main" port="spine"/>
                    </p:input>
                </px:fileset-intersect>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="content-docs" port="fileset"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:group>

    <p:documentation>Create manifest</p:documentation>
    <p:group name="manifest"
             px:message="Creating package document manifest and fileset..." px:message-severity="DEBUG">
        <p:output port="result" primary="true"/>
        <p:output port="as-fileset">
            <p:pipe step="manifest-with-ids" port="result"/>
        </p:output>

        <p:documentation>Give files in the "bindings" fileset media-type "application/xhtml+xml"</p:documentation>
        <p:group name="manifest-with-bindings">
            <p:output port="result" sequence="true"/>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="main" port="bindings"/>
                </p:input>
            </p:identity>
            <px:assert message="There can be at most one set of bindings" test-count-min="0" test-count-max="1" error-code="PEPUTODO"/>
            <p:count/>
            <p:choose>
                <p:when test="/*=0">
                    <p:identity>
                        <p:input port="source">
                            <p:pipe step="source.fileset" port="result"/>
                        </p:input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <px:fileset-intersect>
                        <p:input port="source">
                            <p:pipe step="source.fileset" port="result"/>
                            <p:pipe step="main" port="bindings"/>
                        </p:input>
                    </px:fileset-intersect>
                    <p:set-attributes match="d:file" name="bindings-with-media-type-xhtml">
                        <p:input port="attributes">
                            <p:inline>
                                <d:file media-type="application/xhtml+xml"/>
                            </p:inline>
                        </p:input>
                    </p:set-attributes>
                    <px:fileset-join>
                        <p:input port="source">
                            <p:pipe step="bindings-with-media-type-xhtml" port="result"/>
                            <p:pipe step="source.fileset" port="result"/>
                        </p:input>
                    </px:fileset-join>
                </p:otherwise>
            </p:choose>
        </p:group>
        <p:sink/>

        <p:documentation>Add properties of content documents</p:documentation>
        <p:group name="manifest-with-content-doc-properties">
            <p:for-each>
                <p:iteration-source>
                    <p:pipe step="content-docs" port="in-memory"/>
                </p:iteration-source>
                <p:variable name="doc-base" select="p:base-uri(/*)"/>
                <p:identity name="current"/>
                <px:fileset-create/>
                <px:fileset-add-entry>
                    <p:with-option name="href" select="$doc-base"/>
                    <p:with-option name="media-type" select="'application/xhtml+xml'"/>
                </px:fileset-add-entry>
                <p:choose>
                    <p:when test="$detect-properties='true'">
                        <p:add-attribute attribute-name="mathml" match="/*/*">
                            <p:with-option name="attribute-value" select="distinct-values(//namespace::*)='http://www.w3.org/1998/Math/MathML'">
                                <p:pipe step="current" port="result"/>
                            </p:with-option>
                        </p:add-attribute>
                        <p:add-attribute attribute-name="svg" match="/*/*">
                            <p:with-option name="attribute-value"
                                           select="(//html:embed|//html:iframe)/@src/ends-with(.,'.svg') or
                                                   (//html:embed|//html:object)/@type='image/svg+xml' or
                                                   distinct-values(//namespace::*)='http://www.w3.org/2000/svg'">
                                <p:pipe step="current" port="result"/>
                            </p:with-option>
                        </p:add-attribute>
                        <p:add-attribute attribute-name="scripted" match="/*/*">
                            <p:with-option name="attribute-value"
                                           select="count(//*/@href[starts-with(.,'javascript:')]) &gt; 0 or
                                                   //html:script/@type=('',
                                                   'text/javascript','text/ecmascript','text/javascript1.0','text/javascript1.1',
                                                   'text/javascript1.2','text/javascript1.3','text/javascript1.4','text/javascript1.5',
                                                   'text/jscript','text/livescript','text/x-javascript','text/x-ecmascript',
                                                   'application/x-javascript','application/x-ecmascript','application/javascript',
                                                   'application/ecmascript') or
                                                   //*/@*/name()=('onabort','onafterprint','onbeforeprint','onbeforeunload','onblur','oncanplay',
                                                   'oncanplaythrough','onchange','onclick','oncontextmenu','oncuechange','ondblclick','ondrag',
                                                   'ondragend','ondragenter','ondragleave','ondragover','ondragstart','ondrop','ondurationchange',
                                                   'onemptied','onended','onerror','onfocus','onhashchange','oninput','oninvalid','onkeydown',
                                                   'onkeypress','onkeyup','onload','onloadeddata','onloadedmetadata','onloadstart','onmessage',
                                                   'onmousedown','onmousemove','onmouseout','onmouseover','onmouseup','onmousewheel','onoffline',
                                                   'ononline','onpagehide','onpageshow','onpause','onplay','onplaying','onpopstate','onprogress',
                                                   'onratechange','onreset','onresize','onscroll','onseeked','onseeking','onselect','onshow',
                                                   'onstalled','onstorage','onsubmit','onsuspend','ontimeupdate','onunload','onvolumechange',
                                                   'onwaiting')
                                                   ">
                                <p:pipe step="current" port="result"/>
                            </p:with-option>
                        </p:add-attribute>
                        <p:add-attribute attribute-name="switch" match="/*/*">
                            <p:with-option name="attribute-value" select="count(//epub:switch) &gt; 0">
                                <p:pipe step="current" port="result"/>
                            </p:with-option>
                        </p:add-attribute>
                        <p:add-attribute attribute-name="remote-resources" match="/*/*">
                            <p:with-option name="attribute-value" select="count(//*/@src[contains(tokenize(.,'/')[1],':')][1]) &gt; 0">
                                <p:pipe step="current" port="result"/>
                            </p:with-option>
                        </p:add-attribute>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
                <p:add-attribute attribute-name="nav" match="/*/*">
                    <p:with-option name="attribute-value" select="base-uri(/*)=$doc-base">
                        <p:pipe step="nav-doc" port="result"/>
                    </p:with-option>
                </p:add-attribute>
            </p:for-each>
            <px:fileset-join name="content-docs-with-properties"/>
            <px:fileset-join>
                <p:input port="source">
                    <p:pipe step="content-docs-with-properties" port="result"/>
                    <p:pipe step="manifest-with-bindings" port="result"/>
                </p:input>
            </px:fileset-join>
        </p:group>

        <p:documentation>Add 'cover-image' property</p:documentation>
        <p:add-attribute attribute-name="href" attribute-value="true">
            <p:with-option name="match" select="concat(
                                                  'd:file[resolve-uri(@href,base-uri(.))=&quot;',
                                                  resolve-uri($cover-image,base-uri(/*)),
                                                  '&quot;]')"/>
            
        </p:add-attribute>

        <p:documentation>Add id attributes</p:documentation>
        <p:label-elements name="manifest-with-ids"
                          match="d:file" attribute="id" label="concat('item_',1+count(preceding-sibling::*))"/>

        <p:documentation>Create manifest from fileset</p:documentation>
        <p:xslt name="fileset-to-manifest">
            <p:input port="stylesheet">
                <p:document href="create-package-doc.fileset-to-manifest.xsl"/>
            </p:input>
            <p:with-param name="output-base-uri" select="$output-base-uri"/>
            <p:with-option name="output-base-uri" select="$output-base-uri"/>
        </p:xslt>

        <p:documentation>Assign media overlays</p:documentation>
        <p:xslt px:message="Assigning media overlays to their corresponding content documents..." px:message-severity="DEBUG">
            <p:input port="source">
                <p:pipe step="fileset-to-manifest" port="result"/>
                <p:pipe step="mediaoverlays" port="in-memory"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="assign-media-overlays.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>

        <px:message severity="DEBUG" message="Successfully created package document manifest"/>
    </p:group>
    <p:sink/>

    <p:documentation>Get spine</p:documentation>
    <p:group name="spine">
        <p:output port="result"/>
        <p:group name="spine.secondary">
            <p:output port="result"/>
            <px:fileset-diff>
                <p:input port="source">
                    <p:pipe step="content-docs" port="fileset"/>
                </p:input>
                <p:input port="secondary">
                    <p:pipe step="spine.primary" port="result"/>
                </p:input>
            </px:fileset-diff>
            <p:add-attribute match="/d:fileset/d:file" attribute-name="linear" attribute-value="no"/>
        </p:group>
        <px:fileset-join>
            <p:input port="source">
                <p:pipe step="spine.primary" port="result"/>
                <p:pipe step="spine.secondary" port="result"/>
            </p:input>
        </px:fileset-join>

        <p:documentation>Add idref attributes</p:documentation>
        <p:group>
            <p:viewport match="/*/d:file">
                <p:variable name="href" select="/*/resolve-uri(@href,base-uri(.))"/>
                <p:add-attribute match="/*" attribute-name="idref">
                    <p:with-option name="attribute-value" select="/*/d:file[resolve-uri(@href,base-uri(.))=$href]/@id">
                        <p:pipe step="manifest" port="as-fileset"/>
                    </p:with-option>
                </p:add-attribute>
            </p:viewport>
        </p:group>

        <p:documentation>Create spine from fileset</p:documentation>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="create-package-doc.idref-fileset-to-spine.xsl"/>
            </p:input>
        </p:xslt>

        <p:documentation>Add toc attribute</p:documentation>
        <p:choose>
            <p:xpath-context>
                <p:pipe step="manifest" port="as-fileset"/>
            </p:xpath-context>
            <p:when test="$compatibility-mode='true' and //@media-type='application/x-dtbncx+xml'">
                <p:add-attribute match="/*" attribute-name="toc">
                    <p:with-option name="attribute-value" select="//*[@media-type='application/x-dtbncx+xml']/@id">
                        <p:pipe step="manifest" port="as-fileset"/>
                    </p:with-option>
                </p:add-attribute>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>

        <px:message severity="DEBUG" message="Successfully created package document spine"/>
    </p:group>
    <p:sink/>

    <p:documentation>If the navigation document contains landmarks and compatibility-mode is
    enabled, generate the guide element based on the landmarks.</p:documentation>
    <p:group name="guide">
        <p:output port="result" sequence="true"/>
        <p:filter select="//html:nav[@*[name()='epub:type']='landmarks']" name="guide.landmarks">
            <p:input port="source">
                <p:pipe step="nav-doc" port="result"/>
            </p:input>
        </p:filter>
        <p:count/>
        <p:choose>
            <p:when test="/*=0 or not($compatibility-mode='true')">
                <p:identity px:message="No landmarks in package document" px:message-severity="DEBUG">
                    <p:input port="source">
                        <p:pipe step="guide.landmarks" port="result"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <px:epub3-nav-to-guide px:message="Creating guide element for package document" px:message-severity="DEBUG">
                    <p:input port="source">
                        <p:pipe step="guide.landmarks" port="result"/>
                    </p:input>
                    <p:with-option name="opf-base" select="$output-base-uri"/>
                </px:epub3-nav-to-guide>
                <px:message severity="DEBUG" message="guide element created successfully"/>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:sink/>

    <p:group name="bindings">
        <p:output port="result" sequence="true"/>
        <p:count>
            <p:input port="source">
                <p:pipe step="main" port="bindings"/>
            </p:input>
        </p:count>
        <p:choose>
            <p:when test="/*=0 or not($compatibility-mode='true')">
                <px:message severity="DEBUG" message="No bindings in package document"/>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="main" port="bindings"/>
                    </p:input>
                </p:identity>
                <px:message severity="DEBUG" message="Creating bindings element for package document"/>
                <p:group>
                    <p:viewport match="d:file">
                        <p:variable name="href" select="/*/resolve-uri(@href,base-uri(.))"/>
                        <p:add-attribute match="/*" attribute-name="handler">
                            <p:with-option name="attribute-value"
                                           select="concat('#',/*/d:file[resolve-uri(@href,base-uri(.))=$href]/@id)">
                                <p:pipe step="manifest" port="as-fileset"/>
                            </p:with-option>
                        </p:add-attribute>
                    </p:viewport>
                </p:group>
                <p:xslt>
                    <p:input port="stylesheet">
                        <p:document href="create-package-doc.handler-fileset-to-bindings.xsl"/>
                    </p:input>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                </p:xslt>
                <px:message severity="DEBUG" message="bindings element created successfully"/>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:sink/>

    <p:documentation>Create package document</p:documentation>
    <p:insert match="/*" position="last-child">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <package xmlns="http://www.idpf.org/2007/opf" version="3.0"/>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <!-- TODO declare @prefix -->
            <p:pipe step="metadata" port="result"/>
            <p:pipe step="manifest" port="result"/>
            <p:pipe step="spine" port="result"/>
            <p:pipe step="guide" port="result"/>
            <p:pipe step="bindings" port="result"/>
        </p:input>
    </p:insert>
    <p:add-attribute match="/*" attribute-name="unique-identifier">
        <p:with-option name="attribute-value" select="/opf:package/opf:metadata/dc:identifier/@id"/>
    </p:add-attribute>
    <p:choose>
        <p:when test="/opf:package/opf:metadata/@prefix">
            <p:add-attribute attribute-name="prefix" match="/*">
                <p:with-option name="attribute-value" select="/opf:package/opf:metadata/@prefix"/>
            </p:add-attribute>
            <p:delete match="/opf:package/opf:metadata/@prefix"/>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <px:set-base-uri>
        <p:with-option name="base-uri" select="$output-base-uri"/>
    </px:set-base-uri>
    <px:add-xml-base root="false"/>
    <px:message severity="DEBUG" message="Finished assigning media overlays to content documents"/>

</p:declare-step>
