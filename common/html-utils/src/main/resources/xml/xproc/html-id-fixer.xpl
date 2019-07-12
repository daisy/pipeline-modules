<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                type="px:html-id-fixer"
                version="1.0">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Add missing IDs to HTML document and fix duplicate IDs.</p>
		<p>Adds <code>id</code> attributes on <code>body</code>, <code>article</code>,
		<code>aside</code>, <code>nav</code>, <code>section</code>, <code>h1</code>,
		<code>h2</code>, <code>h3</code>, <code>h4</code>, <code>h5</code>, <code>h6</code>,
		<code>hgroup</code>, and <code>epub:type='pagebreak'</code> elements.</p>
	</p:documentation>
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="../xslt/html-id-fixer.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
</p:declare-step>
