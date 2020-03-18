<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:html-outline">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Apply the <a
		href="https://html.spec.whatwg.org/multipage/sections.html#headings-and-sections">HTML5
		outline algorithm</a>.</p>
		<p>Returns the outline of a HTML document.</p>
	</p:documentation>
	
	<p:input port="source">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2 px:role="name">HTML document</h2>
			<p px:role="desc">The HTML document from which the outline must be extracted.</p>
		</p:documentation>
	</p:input>

	<p:output port="result" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2 px:role="name">The outline</h2>
			<p px:role="desc">The outline of the HTML document as a <code>ol</code> element. Can be
			used directly as a table of contents.</p>
		</p:documentation>
		<p:pipe step="outline" port="result"/>
	</p:output>
	<p:output port="outline">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2 px:role="name">The raw outline</h2>
			<p px:role="desc">The unformatted outline of the HTML document as a
			<code>d:outline</code> document.</p>
		</p:documentation>
		<p:pipe step="raw-outline" port="result"/>
	</p:output>
	<p:output port="content-doc">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2 px:role="name">The modified HTML document.</h2>
			<p px:role="desc">All <code>body</code>, <code>article</code>, <code>aside</code>,
			<code>nav</code>, <code>section</code>, <code>h1</code>, <code>h2</code>,
			<code>h3</code>, <code>h4</code>, <code>h5</code>, <code>h6</code> and
			<code>hgroup</code> elements get an <code>id</code> attribute.</p>
		</p:documentation>
		<p:pipe step="html-with-ids" port="result"/>
	</p:output>

	<p:option name="output-base-uri" required="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The base URI of the resulting outline.</p>
		</p:documentation>
	</p:option>

	<p:import href="html-id-fixer.xpl">
		<p:documentation>
			px:html-id-fixer
		</p:documentation>
	</p:import>

	<p:documentation>Add ID attributes</p:documentation>
	<px:html-id-fixer name="html-with-ids"/>

	<p:documentation>Create the outline</p:documentation>
	<p:xslt name="outline">
		<p:input port="stylesheet">
			<p:document href="../xslt/html5-outliner.xsl"/>
		</p:input>
		<p:with-param name="output-base-uri" select="$output-base-uri"/>
		<p:with-option name="output-base-uri" select="$output-base-uri"/>
	</p:xslt>
	<p:sink/>

	<p:unwrap match="/*//d:outline">
		<p:input port="source">
			<p:pipe step="outline" port="secondary"/>
		</p:input>
	</p:unwrap>
	<p:delete match="/d:outline/@owner" name="raw-outline"/>
	<p:sink/>

</p:declare-step>
