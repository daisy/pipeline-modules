<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:html="http://www.w3.org/1999/xhtml"
                type="px:epub3-nav-create-navigation-doc" name="main">

	<p:input port="source" sequence="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The content documents</p>
			<p>All <code>body</code>, <code>article</code>, <code>aside</code>, <code>nav</code>,
			<code>section</code>, <code>h1</code>, <code>h2</code>, <code>h3</code>,
			<code>h4</code>, <code>h5</code>, <code>h6</code>, <code>hgroup</code> and
			<code>epub:type='pagebreak'</code> elements must have an <code>id</code> attribute (see
			also px:html-id-fixer).</p>
		</p:documentation>
	</p:input>
	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The EPUB navigation document</p>
		</p:documentation>
	</p:output>
	<p:option name="output-base-uri">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The base URI of the resulting navigation document.</p>
		</p:documentation>
	</p:option>
	<p:option name="page-list-hidden" select="'true'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Whether to add a <code>hidden</code> attribute to the
			<code>epub:type='page-list'</code> element.</p>
		</p:documentation>
	</p:option>
	<p:option name="title" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The title of the navigation document.</p>
			<p>If not specified, the title is "Table of contents", localized to the language of the
			content documents.</p>
		</p:documentation>
	</p:option>
	<p:option name="language" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The <code>xml:lang</code> and <code>lang</code> attributes of the navigation
			document.</p>
			<p>If not specified, it will be the language of the content documents.</p>
		</p:documentation>
	</p:option>
	<p:option name="css" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The CSS style sheet to attach to the navigation document.</p>
		</p:documentation>
	</p:option>

	<p:import href="epub3-nav-create-toc.xpl"/>
	<p:import href="epub3-nav-create-page-list.xpl"/>
	<p:import href="epub3-nav-aggregate.xpl"/>
	
	<px:epub3-nav-create-toc name="toc">
		<p:with-option name="output-base-uri" select="$output-base-uri">
			<p:empty/>
		</p:with-option>
	</px:epub3-nav-create-toc>
	<p:sink/>
	
	<px:epub3-nav-create-page-list name="page-list">
		<p:input port="source">
			<p:pipe step="main" port="source"/>
		</p:input>
		<p:with-option name="output-base-uri" select="$output-base-uri">
			<p:empty/>
		</p:with-option>
		<p:with-option name="hidden" select="$page-list-hidden">
			<p:empty/>
		</p:with-option>
	</px:epub3-nav-create-page-list>
	<p:sink/>
	
	<px:epub3-nav-aggregate>
		<p:input port="source">
			<p:pipe step="toc" port="result"/>
			<p:pipe step="page-list" port="result"/>
		</p:input>
		<p:with-option name="output-base-uri" select="$output-base-uri"/>
		<p:with-option name="title" select="$title"/>
		<p:with-option name="language" select="$language"/>
		<p:with-option name="css" select="$css"/>
	</px:epub3-nav-aggregate>
	
</p:declare-step>
