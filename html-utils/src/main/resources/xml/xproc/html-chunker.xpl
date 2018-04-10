<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:html-chunker"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                version="1.0">
	
	<p:input port="source"/>
	<p:output port="result" sequence="true">
		<p:pipe step="xslt" port="secondary"/>
	</p:output>
	
	<p:xslt name="xslt">
		<p:input port="stylesheet">
			<p:document href="../xslt/html-chunker.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	<p:sink/>
	
</p:declare-step>
