<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:chunker"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-inline-prefixes="#all"
                version="1.0"
                name="main">
	
	<p:documentation>
		<p xmlns="http://www.w3.org/1999/xhtml">Break a document into smaller parts.</p>
	</p:documentation>
	
	<p:input port="source"/>
	
	<p:option name="is-chunk" required="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">An XSLTMatchPattern that specifies the break
			points. Each element that matches this expression will be put in its own chunk.</p>
		</p:documentation>
	</p:option>
	
	<p:option name="link-attribute-name" select="'href'">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">The name of the attribute used for links. Every
			attribute with this name that points to an element within the same document (URI with
			only a fragment part) is translated in such a way that in the output the links point to
			the right chunks.</p>
		</p:documentation>
	</p:option>
	
	<p:output port="result" sequence="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">Every output document gets a different base URI
			derived from the input base URI.</p>
		</p:documentation>
	</p:output>
	
	<!--
	    implemented in Java
	-->
	
</p:declare-step>
