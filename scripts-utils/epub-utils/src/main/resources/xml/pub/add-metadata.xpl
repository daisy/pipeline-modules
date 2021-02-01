<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:opf="http://www.idpf.org/2007/opf"
                type="px:epub3-add-metadata"
                name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Inject new metadata into a EPUB package document.</p>
	</p:documentation>

	<p:input port="source" primary="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The input package document</p>
		</p:documentation>
	</p:input>

	<p:input port="metadata">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>A <a
			href="https://www.w3.org/publishing/epub3/epub-packages.html#sec-metadata-elem"><code>opf:metadata</code></a>
			element. A <a
			href="https://www.w3.org/publishing/epub3/epub-packages.html#sec-prefix-attr"><code>prefix</code></a>
			attribute is allowed on the root element.</p>
		</p:documentation>
	</p:input>

	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The output package document with the existing and new metadata merged.</p>
		</p:documentation>
	</p:output>

	<p:option name="compatibility-mode" required="false" select="'true'" px:type="boolean">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Whether to be backward compatible with <a
			href="http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm">Open Package Format
			2.0.1</a>.</p>
		</p:documentation>
	</p:option>

	<p:option name="reserved-prefixes" required="false" select="'#default'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The <a
			href="http://www.idpf.org/epub/301/spec/epub-publications.html#sec-metadata-default-vocab">reserved
			prefix mappings</a> of the resulting package document. By default, prefixes that are
			used but not declared in the input are also not declared in the output.</p>
		</p:documentation>
	</p:option>

	<p:import href="merge-metadata.xpl">
		<p:documentation>
			pxi:merge-metadata
		</p:documentation>
	</p:import>
	<p:import href="opf3-to-opf2-metadata.xpl">
		<p:documentation>
			pxi:opf3-to-opf2-metadata
		</p:documentation>
	</p:import>

	<p:label-elements match="/*[@prefix]/opf:metadata" attribute="prefix" label="../@prefix"/>
	<p:viewport match="/*/opf:metadata" name="metadata-viewport">
		<p:sink/>
		<pxi:merge-metadata>
			<p:input port="source">
				<!-- first occurences win -->
				<p:pipe step="main" port="metadata"/>
				<p:pipe step="metadata-viewport" port="current"/>
			</p:input>
			<p:input port="manifest" select="/*/opf:manifest">
				<p:pipe step="main" port="source"/>
			</p:input>
			<p:with-option name="reserved-prefixes" select="$reserved-prefixes"/>
		</pxi:merge-metadata>
		<!--
		    Add OPF 2 metadata. Note that all OPF 2 metadata that was already present has been
		    removed by the previous step.
		-->
		<p:choose>
			<p:when test="$compatibility-mode='true'">
				<pxi:opf3-to-opf2-metadata compatibility-mode="true"/>
			</p:when>
			<p:otherwise>
				<p:identity/>
			</p:otherwise>
		</p:choose>
	</p:viewport>
	<p:choose>
		<p:when test="/*/opf:metadata/@prefix">
			<p:add-attribute attribute-name="prefix" match="/*">
				<p:with-option name="attribute-value" select="/*/opf:metadata/@prefix"/>
			</p:add-attribute>
			<p:delete match="/*/opf:metadata/@prefix"/>
		</p:when>
		<p:otherwise>
			<p:delete match="/*/@prefix"/>
		</p:otherwise>
	</p:choose>

</p:declare-step>
