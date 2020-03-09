<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:html-id-fixer"
                version="1.0">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Add missing IDs to HTML documents and fix duplicate IDs.</p>
	</p:documentation>

	<p:input port="source" sequence="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The input HTML documents</p>
		</p:documentation>
	</p:input>
	<p:output port="result" sequence="true" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The processed HTML documents</p>
			<p>All <code>body</code>, <code>article</code>, <code>aside</code>, <code>nav</code>,
			<code>section</code>, <code>h1</code>, <code>h2</code>, <code>h3</code>,
			<code>h4</code>, <code>h5</code>, <code>h6</code>, <code>hgroup</code>, and
			<code>epub:type='pagebreak'</code> elements have a <code>id</code> attribute.</p>
			<p>All <code>id</code> attributes are unique within the whole sequence of HTML
			documents.</p>
		</p:documentation>
		<p:pipe step="result" port="result"/>
	</p:output>
	<p:output port="mapping">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p><code>d:fileset</code> document that represents the renaming of <code>id</code>
			attributes.</p>
		</p:documentation>
		<p:pipe step="mapping" port="result"/>
	</p:output>

	<p:for-each>
		<p:add-xml-base/>
	</p:for-each>
	<p:wrap-sequence wrapper="_"/>
	<p:xslt name="xslt">
		<p:input port="stylesheet">
			<p:document href="../xslt/html-id-fixer.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	<p:filter select="/*/*"/>
	<p:for-each>
		<!--
		    we don't know for sure that it was not present in the input, but adding the xml:base is
		    required to preserve the base uri after the wrapping and splitting
		-->
		<p:delete match="/*/@xml:base"/>
	</p:for-each>
	<p:identity name="result"/>
	<p:sink/>

	<p:identity>
		<p:input port="source">
			<p:pipe step="xslt" port="secondary"/>
		</p:input>
	</p:identity>
	<p:delete match="d:file[not(d:anchor)]"/>
	<p:identity name="mapping"/>
	<p:sink/>

</p:declare-step>
