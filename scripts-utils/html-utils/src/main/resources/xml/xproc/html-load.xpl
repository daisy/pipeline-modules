<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:html-load" name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Creates a fileset document for a set of HTML documents.</p>
	</p:documentation>

	<p:input port="source.fileset" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The input fileset containing the HTML files (marked with
			<code>media-type="text/html"</code> or
			<code>media-type="application/xhtml+xml"</code>).</p>
			<p>Will also be used for loading other resources. If files are present in memory, they
			are expected to be <code>c:data</code> documents. Only when files are not present in
			this fileset, it will be attempted to load them from disk.</p>
		</p:documentation>
	</p:input>
	<p:input port="source.in-memory" sequence="true">
		<p:empty/>
	</p:input>

	<p:output port="result.fileset" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The result fileset with the HTML files and all the resources referenced from the
			HTML. Some media types are inferred – users may have to apply additional type
			detection. A <code>@kind</code> attribute is used to annotate the kind of resource:</p>
			<ul>
				<li>stylesheet</li>
				<li>media</li>
				<li>image</li>
				<li>video</li>
				<li>audio</li>
				<li>script</li>
				<li>content</li>
				<li>description</li>
				<li>text-track</li>
				<li>animation</li>
				<li>font</li>
			</ul>
			<p>Only contains resources that actually exist on disk. The HTML documents are loaded
			into memory. The <code>original-href</code> attributes reflects which files are stored
			on disk.</p>
		</p:documentation>
	</p:output>
	<p:output port="result.in-memory" sequence="true">
		<p:pipe step="htmls" port="result"/>
	</p:output>

	<p:option name="handle-xinclude" cx:as="xs:boolean" select="false()">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Apply <a href="https://www.w3.org/TR/xinclude/">XInclude</a> processing on XHTML
			documents.</p>
		</p:documentation>
	</p:option>

	<p:serialization port="result.fileset" indent="true"/>

	<p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
		<p:documentation>
			px:parse-xml-stylesheet-instructions
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
		<p:documentation>
			px:fileset-purge
			px:fileset-load
			px:fileset-join
			px:fileset-intersect
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/library.xpl">
		<p:documentation>
			px:mediatype-detect
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/css-utils/library.xpl">
		<p:documentation>
			px:css-to-fileset
		</p:documentation>
	</p:import>

	<!--
	    remove files that are not on disk or in memory, and make @original-href reflect which files
	    are in memory (this is needed for html-to-fileset.xsl to correctly load resources referenced
	    in CSS)
	-->
	<px:fileset-purge name="purge">
		<p:input port="source.in-memory">
			<p:pipe step="main" port="source.in-memory"/>
		</p:input>
	</px:fileset-purge>

	<p:choose>
		<p:when test="$handle-xinclude">
			<p:add-attribute match="d:file[@media-type='application/xhtml+xml'][not(@method)]"
			                 attribute-name="method"
			                 attribute-value="xml"/>
		</p:when>
		<p:otherwise>
			<p:identity/>
		</p:otherwise>
	</p:choose>
	<px:fileset-load media-types="text/html application/xhtml+xml" detect-serialization-properties="true" name="load">
		<p:input port="in-memory">
			<p:pipe step="main" port="source.in-memory"/>
		</p:input>
	</px:fileset-load>
	<p:choose>
		<p:xpath-context>
			<p:empty/>
		</p:xpath-context>
		<p:when test="$handle-xinclude">
			<p:for-each>
				<p:xinclude/>
			</p:for-each>
		</p:when>
		<p:otherwise>
			<p:identity/>
		</p:otherwise>
	</p:choose>
	<p:identity name="htmls"/>

	<p:for-each>
		<p:identity name="html"/>

		<!-- list HTML files and resources referenced from them -->
		<p:xslt>
			<p:input port="stylesheet">
				<p:document href="../xslt/html-to-fileset.xsl"/>
			</p:input>
			<p:with-param port="parameters" name="context.fileset" select="/">
				<p:pipe step="purge" port="result.fileset"/>
			</p:with-param>
			<p:with-param port="parameters" name="context.in-memory" select="collection()">
				<p:pipe step="main" port="source.in-memory"/>
			</p:with-param>
		</p:xslt>
		<!-- copy detected serialization properties -->
		<p:group>
			<p:identity name="fileset"/>
			<p:sink/>
			<px:fileset-intersect name="files-in-source">
				<p:input port="source">
					<p:pipe step="load" port="result.fileset"/>
					<p:pipe step="fileset" port="result"/>
				</p:input>
			</px:fileset-intersect>
			<p:sink/>
			<px:fileset-join>
				<p:input port="source">
					<p:pipe step="files-in-source" port="result"/>
					<p:pipe step="fileset" port="result"/>
				</p:input>
			</px:fileset-join>
		</p:group>
		<!-- detect media types of resources -->
		<px:mediatype-detect/>
		<p:identity name="html-and-resources"/>
		<p:sink/>

		<px:parse-xml-stylesheet-instructions name="parse-pi">
			<p:input port="source">
				<p:pipe step="html" port="result"/>
			</p:input>
		</px:parse-xml-stylesheet-instructions>
		<p:sink/>
		<p:identity>
			<p:input port="source">
				<p:pipe step="parse-pi" port="fileset"/>
			</p:input>
		</p:identity>
		<p:add-attribute match="d:file" attribute-name="kind" attribute-value="stylesheet" name="stylesheets-from-pi"/>
		<p:sink/>

		<p:group name="referenced-from-css">
			<p:output port="result"/>
			<px:fileset-join>
				<p:input port="source">
					<p:pipe step="html-and-resources" port="result"/>
					<p:pipe step="stylesheets-from-pi" port="result"/>
					<p:pipe step="purge" port="result.fileset"/>
				</p:input>
			</px:fileset-join>
			<px:css-to-fileset>
				<p:input port="source.in-memory">
					<p:pipe step="main" port="source.in-memory"/>
				</p:input>
			</px:css-to-fileset>
		</p:group>
		<p:sink/>

		<px:fileset-join>
			<p:input port="source">
				<p:pipe step="html-and-resources" port="result"/>
				<p:pipe step="stylesheets-from-pi" port="result"/>
				<p:pipe step="referenced-from-css" port="result"/>
			</p:input>
		</px:fileset-join>
	</p:for-each>
	<px:fileset-join/>
	
	<!--
	    remove files that are not on disk or in memory, and make @original-href reflect which files are in memory
	-->
	<px:fileset-purge>
		<p:input port="source.in-memory">
			<p:pipe step="htmls" port="result"/>
			<p:pipe step="main" port="source.in-memory"/>
		</p:input>
	</px:fileset-purge>

	<!--
	    copy attributes from source fileset
	-->
	<p:group>
		<p:identity name="fileset"/>
		<p:sink/>
		<px:fileset-intersect name="files-in-source">
			<p:input port="source">
				<p:pipe step="main" port="source.fileset"/>
				<p:pipe step="fileset" port="result"/>
			</p:input>
		</px:fileset-intersect>
		<p:sink/>
		<px:fileset-join>
			<p:input port="source">
				<p:pipe step="files-in-source" port="result"/>
				<p:pipe step="fileset" port="result"/>
			</p:input>
		</px:fileset-join>
	</p:group>

</p:declare-step>
