<p:declare-step type="px:inline-css-speech" version="1.0" name="main"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		exclude-inline-prefixes="#all">

  <p:documentation>
    Apply CSS Aural stylesheets on documents and return a copy of
    these documents enriched with inlined CSS attributes.
  </p:documentation>

  <p:input port="source" sequence="true" primary="true"/>
  <p:input port="fileset.in"/>
  <p:input port="config"/>
  <p:output port="result"  sequence="true" primary="true"/>

  <p:option name="content-type" required="false" select="''">
    <p:documentation>The type of document to be processed. Other input
    documents will be left unchanged. If no content-type is provided,
    all the documents will be processed.
    </p:documentation>
  </p:option>

  <p:import href="inline-css.xpl"/>
  <p:import href="clean-up-namespaces.xpl"/>

  <p:variable name="style-ns" select="'http://www.daisy.org/ns/pipeline/tts'"/>
  <p:variable name="fileset-base" select="base-uri(/*)">
    <p:pipe port="fileset.in" step="main"/>
  </p:variable>

  <p:for-each name="loop">
    <p:output port="result" sequence="true"/>
    <p:variable name="doc-uri" select="base-uri(/*)"/>
    <p:variable name="type-match"
		select="count(//*[@media-type=$content-type and resolve-uri(@href, $fileset-base)=$doc-uri])">
      <p:pipe port="fileset.in" step="main"/>
    </p:variable>
    <p:choose>
      <p:when test="$type-match = 0 and $content-type != ''">
	<p:output port="result"/>
	<p:identity/>
      </p:when>
      <p:otherwise>
	<p:output port="result"/>
	<px:inline-css>
	  <p:input port="config">
	    <p:pipe port="config" step="main"/>
	  </p:input>
	  <p:with-option name="style-ns" select="$style-ns">
	    <p:empty/>
	  </p:with-option>
	</px:inline-css>
	<px:clean-up-namespaces name="clean-up"/>
      </p:otherwise>
    </p:choose>
  </p:for-each>
</p:declare-step>
