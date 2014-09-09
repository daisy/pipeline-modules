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
  <p:output port="result"  sequence="true" primary="true"/>

  <p:option name="aural-sheet-uri" required="false" select="''">
    <p:documentation>An additional CSS Speech stylesheet that is not
    already referred by the content documents. If such a stylesheet
    is provided, the other stylesheets must not contain any
    'cue-before', 'cue-after', or 'cue' properties with relative
    paths.
    </p:documentation>
  </p:option>

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
	<p:try>
	  <p:group>
	    <p:output port="result" primary="true"/>
	    <p:xslt name="get-css">
	      <p:with-param name="link-element" select="'true'"/>
	      <p:input port="source">
		<p:pipe port="source" step="main"/>
	      </p:input>
	      <p:input port="stylesheet">
		<p:document href="http://www.daisy.org/pipeline/modules/css-utils/xml-to-css-uris.xsl"/>
	      </p:input>
	    </p:xslt>
	    <p:viewport match="//*[@href]">
	      <p:add-attribute attribute-name="original-href" match="/*">
		<p:with-option name="attribute-value" select="resolve-uri(/*/@href, $fileset-base)"/>
	      </p:add-attribute>
	    </p:viewport>
	  </p:group>
	  <p:catch>
	    <p:output port="result" primary="true"/>
	    <px:message message="CSS stylesheet URI(s) are malformed."/>
	    <p:identity>
	      <p:input port="source">
		<p:empty/>
	      </p:input>
	    </p:identity>
	  </p:catch>
	</p:try>
	<p:group>
	  <p:output port="result"/>
	  <p:variable name="sheet-uri-list" select="string-join(//*[@original-href]/@original-href, ',')"/>
	  <p:variable name="all-sheet-uris"
		      select="if ($aural-sheet-uri) then concat($sheet-uri-list, ',', $aural-sheet-uri) else $sheet-uri-list">
	    <p:empty/>
	  </p:variable>
	  <px:message>
	    <p:with-option name="message" select="concat('Stylesheets:', $all-sheet-uris)">
	      <p:empty/>
	    </p:with-option>
	  </px:message>
	  <p:choose name="inlining">
	    <p:when test="$all-sheet-uris != '' and $all-sheet-uris != ','">
	      <p:output port="result"/>
	      <p:identity>
		<p:input port="source">
		  <p:pipe port="source" step="main"/>
		</p:input>
	      </p:identity>
	      <px:inline-css>
		<p:with-option name="stylesheet-uri" select="$all-sheet-uris">
		  <p:empty/> <!-- Otherwise there is more than one document in context. -->
		</p:with-option>
		<p:with-option name="style-ns" select="$style-ns">
		  <p:empty/>
		</p:with-option>
	      </px:inline-css>
	      <px:clean-up-namespaces name="clean-up"/>
	      <px:message message="CSS speech inlined"/>
	    </p:when>
	    <p:otherwise>
	      <p:output port="result"/>
	      <p:identity>
		<p:input port="source">
		  <p:pipe port="source" step="main"/>
		</p:input>
	      </p:identity>
	    </p:otherwise>
	  </p:choose>
	</p:group>
      </p:otherwise>
    </p:choose>
  </p:for-each>
</p:declare-step>
