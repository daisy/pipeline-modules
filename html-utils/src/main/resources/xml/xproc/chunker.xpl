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
	<p:option name="stylesheet" required="true">
		<p:documentation>
			<p xmlns="http://www.w3.org/1999/xhtml">An XSLT style sheet that specifies the break
			points. For each node that should be put in its own chunk, the the style sheet must
			contain a template in the `is-chunk` mode that matches this node and returns
			`true()`.</p>
		</p:documentation>
	</p:option>
	<p:output port="result" sequence="true">
		<p:pipe step="xslt" port="secondary"/>
	</p:output>
	
	<p:string-replace match="/xsl:stylesheet/xsl:include/@href[.='$stylesheet']" name="compile">
		<p:input port="source">
			<p:document href="../xslt/chunker.xsl"/>
		</p:input>
		<p:with-option name="replace" select="concat('&quot;',$stylesheet,'&quot;')"/>
	</p:string-replace>
	
	<p:xslt name="xslt">
		<p:input port="source">
			<p:pipe step="main" port="source"/>
		</p:input>
		<p:input port="stylesheet">
			<p:pipe step="compile" port="result"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	<p:sink/>
	
</p:declare-step>
