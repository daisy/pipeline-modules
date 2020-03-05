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
			<p><code>d:fileset</code> document that contains a mapping from input to output
			files.</p>
		</p:documentation>
		<p:pipe step="skip-if-single" port="mapping"/>
	</p:output>

	<p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
		<p:documentation>
			px:set-base-uri
		</p:documentation>
	</p:import>
	<p:import href="html-update-links.xpl">
		<p:documentation>
			px:html-update-links
		</p:documentation>
	</p:import>

	<p:count name="html-count"/>

	<p:choose name="skip-if-single">
		<p:when test="/*=1">
			<p:output port="result" primary="true"/>
			<p:output port="mapping">
				<p:inline>
					<d:fileset/>
				</p:inline>
			</p:output>
			<p:sink/>
			<p:identity>
				<p:input port="source">
					<p:pipe step="main" port="source"/>
				</p:input>
			</p:identity>
		</p:when>
		<p:otherwise>
			<p:output port="result" primary="true">
				<p:pipe step="result" port="result"/>
			</p:output>
			<p:output port="mapping">
				<p:pipe step="mapping" port="result"/>
			</p:output>
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
					<p:pipe step="main" port="source"/>
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
			<p:identity name="result"/>
			<p:sink/>
			<p:for-each>
				<p:iteration-source>
					<p:pipe step="main" port="source"/>
				</p:iteration-source>
				<p:template>
					<p:input port="template">
						<p:inline>
							<d:file href="{$output-base-uri}" original-href="{base-uri(/*)}"/>
						</p:inline>
					</p:input>
					<p:with-param name="output-base-uri" select="$output-base-uri"/>
				</p:template>
			</p:for-each>
			<p:wrap-sequence wrapper="d:fileset"/>
			<p:identity name="mapping"/>
			<p:sink/>
		</p:otherwise>
	</p:choose>

	<px:set-base-uri>
		<p:with-option name="base-uri" select="$output-base-uri"/>
	</px:set-base-uri>

	<px:html-update-links>
		<p:input port="mapping">
			<p:pipe step="skip-if-single" port="mapping"/>
		</p:input>
	</px:html-update-links>

</p:declare-step>
