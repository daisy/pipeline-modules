<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:dc10="http://purl.org/dc/elements/1.0/"
                xmlns:dc11="http://purl.org/dc/elements/1.1/"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/"
                name="main" type="px:daisy3-load">

    <p:documentation>
        <p px:role="desc">Creates a fileset document based on a DAISY 3 package file.</p>
    </p:documentation>

    <p:input port="source.fileset" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Fileset containing the package file of the input DAISY 3 (marked with
              <code>media-type="application/oebps-package+xml"</code>).</p>
            <p>Will also be used for loading the other manifest items. When items are not present
              in this fileset, it will be attempted to load them from disk.</p>
        </p:documentation>
    </p:input>
    <p:input port="source.in-memory" sequence="true">
        <p:empty/>
    </p:input>

    <p:output port="result.fileset" primary="true" sequence="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The fileset entries are ordered as the appear in the <code>manifest</code> element of
              the input OPF document, except for SMIL documents which are listed in the
              <code>spine</code> order. If more than one DTBook document is found in the fileset, SMIL
              documents are loaded in memory to sort the DTBook documents in the spine order in the
              resulting fileset. Otherwise, only the OPF itself is loaded in memory.</p>
            <p>Note: In the resulting fileset, the media type of SMIL documents will be
              <code>application/smil+xml</code> (as opposed to <code>application/smil</code> in DAISY
              3) and the media type of the OPF document will be
              <code>application/oebps-package+xml</code> (as opposed to <code>text/xml</code> in DAISY
              3). The media type of the NCX, DTBook and resources documents will always be
              <code>application/x-dtbncx+xml</code>, <code>application/x-dtbook+xml</code> and
              <code>application/x-dtbresource+xml</code> (even though in the 1.1.0 version of DAISY
              3 it is <code>text/xml</code>).</p>
        </p:documentation>
    </p:output>
    <p:output port="result.in-memory" sequence="true">
        <p:pipe step="main" port="source.in-memory"/>
        <p:pipe step="fileset-ordered" port="in-memory"/>
    </p:output>

    <p:serialization port="result.fileset" indent="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:assert
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
            px:fileset-join
            px:fileset-intersect
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/smil-utils/library.xpl">
        <p:documentation>
            px:smil-to-text-fileset
        </p:documentation>
    </p:import>

    <px:fileset-load media-types="application/oebps-package+xml" name="load-opf">
        <!-- result fileset is normalized -->
        <p:input port="in-memory">
            <p:pipe step="main" port="source.in-memory"/>
        </p:input>
    </px:fileset-load>
    <px:assert message="There must be exactly one OPF file in the DAISY 3 fileset"
               test-count-min="1" test-count-max="1" error-code="XXXXX"/>

    <p:group name="fileset-from-manifest">
        <p:output port="result"/>
        <p:variable name="opf" select="resolve-uri(base-uri(/*))"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="opf-to-fileset.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <!-- normalize -->
        <px:fileset-join/>
        <px:assert message="There must be exactly one OPF item in the OPF manifest and it must point to the OPF itself">
            <p:with-option name="test" select="count(//d:file[@media-type='application/oebps-package+xml'])=1
                                               and //d:file[@media-type='application/oebps-package+xml'][resolve-uri(@href,base-uri(.))=$opf]"/>
        </px:assert>
        <px:assert message="There must be exactly one NCX item in the OPF manifest">
            <p:with-option name="test" select="count(//d:file[@media-type='application/x-dtbncx+xml'])=1"/>
        </px:assert>
        <p:identity name="fileset-from-manifest-without-attrs"/>
        <!--
            add file attributes
        -->
        <p:sink/>
        <px:fileset-join name="join">
            <p:input port="source">
                <p:pipe step="fileset-from-manifest-without-attrs" port="result"/>
                <p:pipe step="load-opf" port="unfiltered.fileset"/>
            </p:input>
        </px:fileset-join>
        <px:fileset-intersect>
            <p:input port="source">
                <p:pipe step="join" port="result"/>
                <p:pipe step="fileset-from-manifest-without-attrs" port="result"/>
            </p:input>
        </px:fileset-intersect>
    </p:group>

    <p:group name="fileset-ordered">
        <p:output port="fileset" primary="true"/>
        <p:output port="in-memory" sequence="true">
            <p:pipe step="choose" port="in-memory"/>
        </p:output>
        <!-- re-order the DTBook entries in the file set -->
        <p:choose name="choose">
            <p:when test="count(//d:file[@media-type='application/x-dtbook+xml'])&gt;1">
                <!-- when there is more than one DTBook, delete all entries and re-compute them by
                     parsing each SMIL file -->
                <p:output port="fileset" primary="true"/>
                <p:output port="in-memory" sequence="true">
                    <p:pipe step="load-smils" port="result"/>
                </p:output>
                <p:delete match="d:file[@media-type='application/x-dtbook+xml']"/>
                <px:fileset-load media-types="application/smil+xml" name="load-smils"/>
                <p:for-each name="dtbook-fileset-without-attrs">
                    <p:output port="result"/>
                    <p:iteration-source>
                        <p:pipe step="load-smils" port="result"/>
                    </p:iteration-source>
                    <px:smil-to-text-fileset/>
                    <p:add-attribute match="d:file"
                                     attribute-name="media-type"
                                     attribute-value="application/x-dtbook+xml"/>
                </p:for-each>
                <p:sink/>
                <!--
                    join and add file attributes
                -->
                <px:fileset-join>
                    <p:input port="source">
                        <p:pipe step="load-smils" port="unfiltered.fileset"/>
                        <p:pipe step="dtbook-fileset-without-attrs" port="result"/>
                        <p:pipe step="fileset-from-manifest" port="result"/>
                    </p:input>
                </px:fileset-join>
            </p:when>
            <p:otherwise>
                <p:output port="fileset" primary="true"/>
                <p:output port="in-memory" sequence="true">
                    <p:empty/>
                </p:output>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:group>

</p:declare-step>
