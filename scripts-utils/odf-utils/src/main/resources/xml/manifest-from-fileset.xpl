<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:odf-manifest-from-fileset" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                name="main">
	
	<p:input port="source">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>A d:fileset manifest</p>
		</p:documentation>
	</p:input>
	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>A <a
			href="http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part3.html#Manifest_File">ODF
			manifest document</a></p>
		</p:documentation>
	</p:output>
	<p:option name="base" required="false" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The base directory for which to make the manifest. Defaults to the file that has a
			media-type that starts with application/vnd.oasis.opendocument, or if no such file
			exists, the base-uri of the d:fileset element. Files that are not inside the base
			directory are not included in the manifest.</p>
		</p:documentation>
	</p:option>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="manifest-from-fileset.xsl"/>
		</p:input>
		<p:with-param name="param-base" select="$base"/>
	</p:xslt>
	
</p:declare-step>
