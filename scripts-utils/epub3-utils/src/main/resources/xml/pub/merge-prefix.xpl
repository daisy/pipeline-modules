<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                exclude-inline-prefixes="#all"
                type="px:epub3-pub-merge-prefix">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Merge <code>prefix</code> attributes</p>
	</p:documentation>

	<p:input port="source">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>OPF document that may have more than one <code>prefix</code> attribute.</p>
			<p><code>prefix</code> attributes are allowed on any element, not only on
			<code>package</code> or <code>html</code>, but it is assumed that any element only has
			one ancestor element with a <code>prefix</code>.</p>
		</p:documentation>
	</p:input>

	<p:option name="reserved-prefixes" required="true"/>

	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The result document has at most one <code>prefix</code> attribute, on the root
			element. The different <code>prefix</code> attributes in the input document are merged
			in such a way that every prefix is unique and no two prefixes are mapped to the same
			URI. The document is updated at the places where a prefix is used that was
			renamed. Prefixes that are not used anywhere inside the document are skipped from the
			declaration.</p>
		</p:documentation>
	</p:output>

	<p:xslt name="metadata-with-merged-prefix">
		<p:input port="stylesheet">
			<p:document href="merge-prefix.xsl"/>
		</p:input>
		<p:with-param name="reserved-prefixes" select="$reserved-prefixes">
			<p:empty/>
		</p:with-param>
	</p:xslt>

</p:declare-step>
