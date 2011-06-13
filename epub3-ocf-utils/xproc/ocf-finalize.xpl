<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-ocf-finalize" name="main" 
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal"
    version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:input port="metadata" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="rights" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="signature" sequence="true">
        <p:empty/>
    </p:input>
    <p:option name="create-odf-manifest" select="'false'"/>
    <p:output port="result" primary="true"/>
    <p:output port="container">
        <p:pipe port="result" step="create-container-descriptor"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>

    <p:declare-step type="pxi:store-in-ocf" name="store-in-ocf">
        <p:input port="fileset" primary="true"/>
        <p:input port="source" sequence="true"/>
        <p:option name="path" required="true"/>
        <p:option name="media-type"/>
        <p:output port="result"/>

        <p:wrap-sequence wrapper="wrapper">
            <p:input port="source">
                <p:pipe port="source" step="store-in-ocf"/>
            </p:input>
        </p:wrap-sequence>
        <p:choose>
            <p:when test="count(wrapper/*)=0">
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="fileset" step="store-in-ocf"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:when test="count(wrapper/*)>1">
                <p:error code="err:EOU001">
                    <p:input port="source">
                        <p:inline>
                            <c:message>It is a dynamic error if more than one document appears on
                                the source port.</c:message>
                        </p:inline>
                    </p:input>
                </p:error>
            </p:when>
            <p:otherwise>
                <!-- Store container descriptor -->
                <p:unwrap match="/wrapper"/>

                <!-- Add the container descriptor to the fileset document -->
                <p:choose>
                    <p:when test="p:value-available('media-type')">
                        <p:store indent="true" encoding="utf-8" omit-xml-declaration="false">
                            <p:with-option name="method" select="if($path='mimetype') then 'text' else 'xml'"/>
                            <p:with-option name="media-type" select="$media-type"/>
                            <p:with-option name="href" select="resolve-uri($path,base-uri(/*))">
                                <p:pipe port="fileset" step="store-in-ocf"/>
                            </p:with-option>
                        </p:store>
                        <px:fileset-add-entry>
                            <p:with-option name="href" select="$path"/>
                            <p:with-option name="first" select="$path='mimetype'"/>
                            <p:with-option name="media-type" select="$media-type"/>
                            <p:input port="source">
                                <p:pipe port="fileset" step="store-in-ocf"/>
                            </p:input>
                        </px:fileset-add-entry>
                    </p:when>
                    <p:otherwise>
                        <p:store indent="true" encoding="utf-8" omit-xml-declaration="false">
                            <p:with-option name="method" select="if($path='mimetype') then 'text' else 'xml'"/>
                            <p:with-option name="href" select="resolve-uri($path,base-uri(/*))">
                                <p:pipe port="fileset" step="store-in-ocf"/>
                            </p:with-option>
                        </p:store>
                        <px:fileset-add-entry>
                            <p:with-option name="href" select="$path"/>
                            <p:with-option name="first" select="$path='mimetype'"/>
                            <p:input port="source">
                                <p:pipe port="fileset" step="store-in-ocf"/>
                            </p:input>
                        </px:fileset-add-entry>
                    </p:otherwise>
                </p:choose>
            </p:otherwise>
        </p:choose>
    </p:declare-step>

    <p:wrap-sequence name="opf-files" wrapper="wrapper">
        <p:input port="source"
            select="//*[@media-type='application/oebps-package+xml' or ends-with(@href,'.opf')]">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:wrap-sequence>

    <p:group name="create-mimetype">
        <p:output port="result"/>
        <!-- Create a c:data with the mimetype content -->
        <p:string-replace match="text()" replace="normalize-space()">
            <p:input port="source">
                <p:inline>
                    <c:data>application/epub+zip</c:data>
                </p:inline>
            </p:input>
        </p:string-replace>
    </p:group>

    <p:group name="create-container-descriptor">
        <p:output port="result"/>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="result" step="opf-files"/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:d="http://www.daisy.org/ns/pipeline/data"
                        xmlns="urn:oasis:names:tc:opendocument:xmlns:container" 
                        exclude-result-prefixes="#all" version="2.0">
                        <xsl:template match="wrapper">
                            <container version="1.0">
                                <rootfiles>
                                    <xsl:apply-templates/>
                                </rootfiles>
                            </container>
                        </xsl:template>
                        <xsl:template match="d:file">
                            <rootfile full-path="{@href}" media-type="application/oebps-package+xml"
                            />
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:group>

    <p:group name="create-odf-manifest"
        xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
        <p:output port="result" sequence="true"/>
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="before-odf"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:when test="$create-odf-manifest = 'true'">
                <p:xslt>
                    <p:input port="stylesheet">
                        <p:document
                            href="http://www.daisy.org/pipeline/modules/fileset-utils/xslt/fileset-to-odf-manifest.xsl"
                        />
                    </p:input>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                </p:xslt>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:filter select="/manifest:manifest"/>
    </p:group>

    <p:choose name="check-fileset">
        <p:xpath-context>
            <p:pipe port="result" step="opf-files"/>
        </p:xpath-context>
        <p:when test="not(wrapper/*)">
            <p:error code="err:EOU002">
                <p:input port="source">
                    <p:inline>
                        <c:message>No OPF was found in the source file set.</c:message>
                    </p:inline>
                </p:input>
            </p:error>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="source" step="main"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <pxi:store-in-ocf path="mimetype">
        <p:input port="source">
            <p:pipe port="result" step="create-mimetype"/>
        </p:input>
    </pxi:store-in-ocf>
    <pxi:store-in-ocf path="META-INF/container.xml" media-type="application/oebps-package+xml">
        <p:input port="source">
            <p:pipe port="result" step="create-container-descriptor"/>
        </p:input>
    </pxi:store-in-ocf>
    <pxi:store-in-ocf path="META-INF/metadata.xml">
        <p:input port="source">
            <p:pipe port="metadata" step="main"/>
        </p:input>
    </pxi:store-in-ocf>
    <pxi:store-in-ocf path="META-INF/rights.xml">
        <p:input port="source">
            <p:pipe port="rights" step="main"/>
        </p:input>
    </pxi:store-in-ocf>
    <pxi:store-in-ocf path="META-INF/signature.xml">
        <p:input port="source">
            <p:pipe port="signature" step="main"/>
        </p:input>
    </pxi:store-in-ocf>
    <p:identity name="before-odf"/>
    <!-- Finally -->
    <pxi:store-in-ocf path="META-INF/manifest.xml">
        <p:input port="source">
            <p:pipe port="result" step="create-odf-manifest"/>
        </p:input>
    </pxi:store-in-ocf>
    <p:identity name="fileset-finalized"/>


</p:declare-step>
