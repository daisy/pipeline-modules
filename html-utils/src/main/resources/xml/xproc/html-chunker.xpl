<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:html-chunker"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:html="http://www.w3.org/1999/xhtml"
                exclude-inline-prefixes="#all"
                version="1.0"
                name="main">
	
	<p:documentation>
		<p xmlns="http://www.w3.org/1999/xhtml">Break a HTML document into smaller parts based on
			its structure.</p>
	</p:documentation>
	
	<p:input port="source"/>
	<p:output port="result" sequence="true"/>
	
	<p:import href="chunker.xpl"/>
	
	<p:delete match="/html:html/html:head"/>

	<px:chunker>
		<p:with-option name="stylesheet" select="resolve-uri('../xslt/html-chunker-break-points.xsl')">
			<p:inline>
				<this/>
			</p:inline>
		</p:with-option>
	</px:chunker>
	
	<p:for-each name="chunks">
		<p:xslt>
			<p:input port="source">
				<p:pipe step="chunks" port="current"/>
				<p:pipe step="main" port="source"/>
			</p:input>
			<p:input port="stylesheet">
				<p:document href="../xslt/html-chunker-finalize.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
		</p:xslt>
	</p:for-each>
	
</p:declare-step>
