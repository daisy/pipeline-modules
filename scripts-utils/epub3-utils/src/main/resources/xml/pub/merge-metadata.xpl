<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                exclude-inline-prefixes="#all"
                type="pxi:merge-metadata" name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Merge and augment EPUB Publications metadata</p>
	</p:documentation>

	<p:input port="source" sequence="true" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>A set of 'metadata' documents in the OPF namespace</p>
		</p:documentation>
	</p:input>

	<p:input port="manifest">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The 'manifest' document</p>
		</p:documentation>
	</p:input>

	<p:option name="reserved-prefixes" required="true"/>

	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>A single 'metadata' document in the OPF namespace, containing in 'merged'
			metadata</p>
		</p:documentation>
	</p:output>

	<p:wrap-sequence wrapper="_" name="wrapped-metadata">
		<!-- wrap input documents in a common root element (the name of the wrapper is insignificant) -->
	</p:wrap-sequence>

	<p:xslt>
		<p:input port="source">
			<p:pipe step="wrapped-metadata" port="result"/>
			<p:pipe step="main" port="manifest"/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="create-metadata.merge.xsl"/>
		</p:input>
		<p:with-param name="reserved-prefixes" select="$reserved-prefixes">
			<p:empty/>
		</p:with-param>
	</p:xslt>

</p:declare-step>
