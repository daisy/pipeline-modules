<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:html-to-epub3" name="main"
                exclude-inline-prefixes="#all" version="1.0">

    <p:documentation>Transforms XHTML into an EPUB 3 publication.</p:documentation>

    <p:input port="input.fileset" primary="true"/>
    <p:input port="input.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>HTML document(s)</p>
        </p:documentation>
    </p:input>
    <p:input port="metadata" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>HTML documents to extract metadata from</p>
        </p:documentation>
        <p:empty/>
    </p:input>

    <p:output port="fileset.out" primary="true"/>
    <p:output port="in-memory.out" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The EPUB 3 publication (not zipped)</p>
        </p:documentation>
        <p:pipe step="ocf" port="in-memory"/>
    </p:output>

    <p:option name="output-dir" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/epub3-utils/library.xpl">
        <p:documentation>
            px:epub3-nav-create-navigation-doc
            px:epub3-pub-create-package-doc
            px:epub3-ocf-finalize
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
            px:fileset-filter
            px:fileset-add-entry
            px:fileset-join
            px:fileset-rebase
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:assert
            px:message
        </p:documentation>
    </p:import>
    <p:import href="html-to-epub3.content.xpl"/>
    <p:import href="html-to-opf-metadata.xpl"/>

    <p:variable name="epub-dir" select="concat($output-dir,'epub/')">
        <p:empty/>
    </p:variable>
    <p:variable name="content-dir" select="concat($epub-dir,'EPUB/')">
        <p:empty/>
    </p:variable>

    <!--=========================================================================-->
    <!-- LOAD XHTML                                                              -->
    <!--=========================================================================-->

    <px:fileset-load media-types="application/xhtml+xml">
        <p:input port="in-memory">
            <p:pipe step="main" port="input.in-memory"/>
        </p:input>
    </px:fileset-load>
    <px:assert message="No XHTML documents found." test-count-min="1" error-code="PEZE00"/>
    <p:identity name="html"/>
    <p:sink/>

    <px:fileset-filter not-media-types="application/xhtml+xml" name="resources">
        <p:input port="source">
            <p:pipe step="main" port="input.fileset"/>
        </p:input>
    </px:fileset-filter>

    <!--=========================================================================-->
    <!-- CLEAN THE XHTML Content Documents                                       -->
    <!--=========================================================================-->

    <p:documentation>Clean the XHTML Documents</p:documentation>
    <pxi:html-to-epub3-content name="content-docs">
        <p:with-option name="publication-dir" select="$epub-dir">
            <p:empty/>
        </p:with-option>
        <p:with-option name="content-dir" select="$content-dir">
            <p:empty/>
        </p:with-option>
        <p:input port="html">
            <p:pipe step="html" port="result"/>
        </p:input>
        <p:input port="fileset.in.resources">
            <p:pipe step="resources" port="result"/>
        </p:input>
    </pxi:html-to-epub3-content>

    <!--=========================================================================-->
    <!-- GENERATE THE NAVIGATION DOCUMENT                                        -->
    <!--=========================================================================-->

    <p:documentation>Generate the EPUB 3 navigation document</p:documentation>
    <p:group name="add-navigation-doc">
        <p:output port="fileset" primary="true"/>
        <p:output port="in-memory" sequence="true">
            <p:pipe step="add-entry" port="result.in-memory"/>
        </p:output>
        <p:output port="doc">
            <p:pipe step="navigation-doc" port="result"/>
        </p:output>

        <!--TODO create other nav types (configurable ?)-->
        <px:epub3-nav-create-navigation-doc>
            <p:input port="source">
                <p:pipe port="docs" step="content-docs"/>
            </p:input>
            <p:with-option name="output-base-uri" select="concat($content-dir,'toc.xhtml')">
                <p:empty/>
            </p:with-option>
        </px:epub3-nav-create-navigation-doc>
        <px:message message="Navigation Document Created."/>
        <p:identity name="navigation-doc"/>
        <p:sink/>

        <px:fileset-join>
            <p:input port="source">
                <p:pipe step="content-docs" port="fileset.out.docs"/>
                <p:pipe step="content-docs" port="fileset.out.resources"/>
            </p:input>
        </px:fileset-join>
        <px:fileset-add-entry media-type="application/xhtml+xml" name="add-entry">
            <p:input port="source.in-memory">
                <p:pipe step="content-docs" port="docs"/>
                <p:pipe step="content-docs" port="resources"/>
            </p:input>
            <p:input port="entry">
                <p:pipe step="navigation-doc" port="result"/>
            </p:input>
        </px:fileset-add-entry>
    </p:group>
    <p:sink/>

    <!--=========================================================================-->
    <!-- METADATA                                                                -->
    <!--=========================================================================-->

    <p:documentation>Extract metadata</p:documentation>
    <!--TODO adapt to multiple XHTML input docs-->
    <pxi:html-to-opf-metadata name="metadata">
        <p:input port="source">
            <p:pipe step="content-docs" port="docs"/>
        </p:input>
    </pxi:html-to-opf-metadata>
    <p:sink/>

    <!--=========================================================================-->
    <!-- GENERATE THE PACKAGE DOCUMENT                                           -->
    <!--=========================================================================-->
    <p:documentation>Generate the EPUB 3 package document</p:documentation>
    <p:group name="add-package-doc">
        <p:output port="fileset" primary="true"/>
        <p:output port="in-memory" sequence="true">
            <p:pipe step="add-entry" port="result.in-memory"/>
        </p:output>

        <px:epub3-pub-create-package-doc compatibility-mode="false">
            <p:input port="source.fileset">
                <p:pipe step="add-navigation-doc" port="fileset"/>
            </p:input>
            <p:input port="source.in-memory">
                <p:pipe step="add-navigation-doc" port="in-memory"/>
            </p:input>
            <p:input port="spine">
                <p:pipe step="content-docs" port="fileset.out.docs"/>
            </p:input>
            <p:input port="metadata">
                <p:pipe step="main" port="metadata"/>
                <p:pipe step="metadata" port="result"/>
            </p:input>
            <p:with-option name="output-base-uri" select="concat($content-dir,'package.opf')"/>
        </px:epub3-pub-create-package-doc>
        <px:message message="Package Document Created."/>
        <p:identity name="package-doc"/>
        <p:sink/>

        <px:fileset-add-entry media-type="application/oebps-package+xml" name="add-entry">
            <p:input port="source">
                <p:pipe step="add-navigation-doc" port="fileset"/>
            </p:input>
            <p:input port="source.in-memory">
                <p:pipe step="add-navigation-doc" port="in-memory"/>
            </p:input>
            <p:input port="entry">
                <p:pipe step="package-doc" port="result"/>
            </p:input>
        </px:fileset-add-entry>
    </p:group>

    <!--=========================================================================-->
    <!-- GENERATE THE OCF DOCUMENTS                                              -->
    <!-- (container.xml, manifest.xml, metadata.xml, rights.xml, signature.xml)  -->
    <!--=========================================================================-->

    <!--
        change fileset base from EPUB/ directory to top directory because this is what
        px:epub3-ocf-finalize expects
    -->
    <px:fileset-rebase>
        <p:with-option name="new-base" select="$epub-dir"/>
    </px:fileset-rebase>

    <!--TODO clean file set for non-existing files ?-->

    <p:group name="ocf">
        <p:output port="fileset" primary="true">
            <p:pipe step="ocf-finalize" port="result"/>
        </p:output>
        <p:output port="in-memory" sequence="true">
            <p:pipe step="in-memory" port="result.in-memory"/>
        </p:output>
        <px:epub3-ocf-finalize name="ocf-finalize"/>
        <p:documentation>
            Remove files from memory that are not in fileset
        </p:documentation>
        <px:fileset-update name="in-memory">
            <p:input port="source.in-memory">
                <p:pipe step="ocf-finalize" port="in-memory.out"/>
                <p:pipe step="add-package-doc" port="in-memory"/>
            </p:input>
             <p:input port="update">
                 <!-- update empty because only calling px:fileset-update for purging in-memory port -->
                <p:empty/>
            </p:input>
        </px:fileset-update>
        <p:sink/>
    </p:group>

</p:declare-step>
