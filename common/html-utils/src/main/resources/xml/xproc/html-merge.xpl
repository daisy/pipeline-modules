<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:html="http://www.w3.org/1999/xhtml"
                exclude-inline-prefixes="#all"
                type="px:html-merge" name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Merge multiple HTML documents into a single document.</p>
	</p:documentation>

	<p:input port="source" sequence="true"/>
	<p:option name="output-base-uri" required="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The base URI of the result document.</p>
		</p:documentation>
	</p:option>
	<p:output port="result" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The result is a simple concatenation of all the <code>body</code> elements, renamed
			to <code>section</code>. The <code>head</code> element is empty.</p>
		</p:documentation>
	</p:output>
	<p:output port="mapping">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p><code>d:fileset</code> document that contains a mapping from input to output files
			and contained <code>id</code> attributes.</p>
		</p:documentation>
		<p:pipe step="mapping" port="result"/>
	</p:output>

	<p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
		<p:documentation>
			px:set-base-uri
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
		<p:documentation>
			px:fileset-compose
		</p:documentation>
	</p:import>
	<p:import href="html-update-links.xpl">
		<p:documentation>
			px:html-update-links
		</p:documentation>
	</p:import>
	<p:import href="html-add-ids.xpl">
		<p:documentation>
			px:html-add-ids
		</p:documentation>
	</p:import>

	<!--
	    fix duplicate ids
	-->
	<px:html-add-ids name="fix-ids"/>
	<p:count name="html-count"/>
	<p:sink/>

	<!--
	    file mapping
	-->
	<p:group name="file-mapping">
		<p:output port="result"/>
		<p:for-each>
			<p:iteration-source>
				<p:pipe step="main" port="source"/>
			</p:iteration-source>
			<p:variable name="input-base-uri" select="base-uri(/*)"/>
			<p:for-each>
				<p:iteration-source select="//*[@id|@xml:id]"/>
				<p:template>
					<p:input port="template">
						<p:inline>
							<d:anchor id="{/*/(@xml:id,@id)[1]}"/>
						</p:inline>
					</p:input>
					<p:input port="parameters">
						<p:empty/>
					</p:input>
				</p:template>
			</p:for-each>
			<p:wrap-sequence wrapper="d:file"/>
			<p:add-attribute match="/*" attribute-name="href">
				<p:with-option name="attribute-value" select="$output-base-uri">
					<p:empty/>
				</p:with-option>
			</p:add-attribute>
			<p:add-attribute match="/*" attribute-name="original-href">
				<p:with-option name="attribute-value" select="$input-base-uri">
					<p:empty/>
				</p:with-option>
			</p:add-attribute>
		</p:for-each>
		<p:wrap-sequence wrapper="d:fileset"/>
	</p:group>
	<p:sink/>

	<!--
	    file mapping + id mapping
	-->
	<px:fileset-compose name="mapping">
		<p:input port="source">
			<p:pipe step="fix-ids" port="mapping"/>
			<p:pipe step="file-mapping" port="result"/>
		</p:input>
	</px:fileset-compose>
	<p:sink/>

	<!--
	    update links
	-->
	<p:for-each name="update-links">
		<p:iteration-source>
			<p:pipe step="fix-ids" port="result"/>
		</p:iteration-source>
		<p:output port="result"/>
		<!--
		    first make links that point to a file (without a fragment) point to the body element of that file
		-->
		<p:xslt>
			<p:input port="source">
				<p:pipe step="update-links" port="current"/>
				<p:pipe step="fix-ids" port="result"/>
			</p:input>
			<p:input port="stylesheet">
				<p:document href="../xslt/add-link-fragments.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
		</p:xslt>
		<!--
		    then update links according to file/id mapping
		-->
		<px:html-update-links>
			<p:input port="mapping">
				<p:pipe step="mapping" port="result"/>
			</p:input>
		</px:html-update-links>
	</p:for-each>

	<!--
	    merge
	-->
	<p:choose>
		<p:xpath-context>
			<p:pipe step="html-count" port="result"/>
		</p:xpath-context>
		<p:when test="/*=1">
			<p:identity/>
		</p:when>
		<p:otherwise>
			<p:sink/>
			<p:identity name="head">
				<p:input port="source">
					<p:inline>
						<html:head/>
					</p:inline>
				</p:input>
			</p:identity>
			<p:sink/>
			<p:for-each>
				<p:iteration-source>
					<p:pipe step="update-links" port="result"/>
				</p:iteration-source>
				<p:filter select="//html:body"/>
				<p:rename match="/*" new-name="html:section"/>
			</p:for-each>
			<p:wrap-sequence wrapper="html:body" name="body"/>
			<p:sink/>
			<p:wrap-sequence wrapper="html:html">
				<p:input port="source">
					<p:pipe step="head" port="result"/>
					<p:pipe step="body" port="result"/>
				</p:input>
			</p:wrap-sequence>
		</p:otherwise>
	</p:choose>
	<px:set-base-uri>
		<p:with-option name="base-uri" select="$output-base-uri"/>
	</px:set-base-uri>

</p:declare-step>
