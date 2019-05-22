<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:html="http://www.w3.org/1999/xhtml"
                type="px:nordic-html-add-accessibility-css.step"
                name="main">

    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true">
        <p:empty/>
    </p:input>
    <p:output port="fileset.out" primary="true"/>

    <p:output port="in-memory.out" sequence="true">
      <p:pipe step="choose" port="in-memory"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
      <p:documentation>
        px:fileset-load
        px:fileset-create
        px:fileset-add-entry
        px:fileset-update
        px:fileset-store
        px:fileset-join
      </p:documentation>
    </p:import>

    <px:fileset-load media-types="application/xhtml+xml" name="load-html">
      <p:input port="in-memory">
        <p:pipe port="in-memory.in" step="main"/>
      </p:input>
    </px:fileset-load>

    <!--
        if validation-status = error, there could be 0 documents on the input port, therefore use p:for-each
    -->
    <p:for-each name="insert-css-link">
      <p:output port="result" sequence="true"/>
      <!--
          Link to the CSS style sheet from the HTML.
      -->
      <p:insert match="/html:html/html:head" position="last-child">
        <p:input port="insertion">
          <p:inline exclude-inline-prefixes="#all">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="css/accessibility.css"/>
          </p:inline>
        </p:input>
      </p:insert>
    </p:for-each>

    <p:count/>
    <p:choose name="choose">
      <p:when test=".='0'">
        <p:output port="fileset" primary="true"/>
        <p:output port="in-memory" sequence="true">
          <p:pipe step="main" port="in-memory.in"/>
        </p:output>
        <p:identity>
          <p:input port="source">
            <p:pipe step="main" port="fileset.in"/>
          </p:input>
        </p:identity>
      </p:when>
      <p:otherwise>
        <p:output port="fileset" primary="true"/>
        <p:output port="in-memory" sequence="true">
          <p:pipe step="update" port="result.in-memory"/>
        </p:output>

        <p:variable name="html-base" select="base-uri(/)">
          <p:pipe step="insert-css-link" port="result"/>
        </p:variable>
        <p:variable name="xproc-base" select="base-uri(/)">
          <p:inline>
            <irrelevant/>
          </p:inline>
        </p:variable>

        <!--
            Add the resources to the fileset
        -->
        <px:fileset-create/>
        <px:fileset-add-entry media-type="text/css">
          <p:with-option name="original-href" select="resolve-uri('../../../css/accessibility.css', $xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/accessibility.css', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-add-entry media-type="application/x-font-opentype">
          <p:with-option name="original-href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-Regular.otf',$xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-Regular.otf', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-add-entry media-type="application/x-font-opentype">
          <p:with-option name="original-href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-Italic.otf',$xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-Italic.otf', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-add-entry media-type="application/x-font-opentype">
          <p:with-option name="original-href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-Bold.otf',$xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-Bold.otf', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-add-entry media-type="application/x-font-opentype">
          <p:with-option name="original-href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexic-BoldItalic.otf',$xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/OpenDyslexic-BoldItalic.otf', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-add-entry media-type="application/x-font-opentype">
          <p:with-option name="original-href" select="resolve-uri('../../../css/fonts/opendyslexic/OpenDyslexicMono-Regular.otf',$xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/OpenDyslexicMono-Regular.otf', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-add-entry >
          <p:with-option name="original-href" select="resolve-uri('../../../css/fonts/opendyslexic/LICENSE.txt',$xproc-base)"/>
          <p:with-option name="href" select="resolve-uri('css/fonts/opendyslexic/LICENSE.txt', $html-base)"/>
        </px:fileset-add-entry>
        <px:fileset-store name="store-css">
          <p:input port="in-memory.in">
            <p:empty/>
          </p:input>
        </px:fileset-store>

        <!--
            Merge HTML, CSS and other resources
        -->
        <px:fileset-join>
          <p:input port="source">
            <p:pipe step="main" port="fileset.in"/>
            <p:pipe step="store-css" port="fileset.out"/>
          </p:input>
        </px:fileset-join>
        <px:fileset-update name="update">
          <p:input port="source.in-memory">
            <p:pipe step="main" port="in-memory.in"/>
          </p:input>
          <p:input port="update">
            <p:pipe step="insert-css-link" port="result"/>
          </p:input>
        </px:fileset-update>
      </p:otherwise>
    </p:choose>

</p:declare-step>

