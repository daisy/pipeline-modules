<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:opf-spine-to-fileset" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                name="main">

	<p:input port="source.fileset" primary="true"/>
	<p:input port="source.in-memory" sequence="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The input EPUB3</p>
			<p>Must contain a file with media-type "application/oebps-package+xml".</p>
		</p:documentation>
	</p:input>
	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The filtered fileset manifest with only the content items in spine order.</p>
			<p>Missing "media-type" attributes are added based on the info in the package
			document.</p>
		</p:documentation>
	</p:output>

	<p:option name="ignore-missing" select="'false'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Whether to ignore spine items that are not present in the input fileset, or throw an
			error.</p>
		</p:documentation>
	</p:option>

	<p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
		<p:documentation>
			px:assert
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
		<p:documentation>
			px:fileset-load
			px:fileset-filter
			px:fileset-join
		</p:documentation>
	</p:import>

	<px:fileset-join name="source.fileset">
		<!-- normalize @href -->
	</px:fileset-join>

	<px:fileset-load media-types="application/oebps-package+xml">
		<!-- this also normalizes base URI of OPF -->
		<p:input port="in-memory">
			<p:pipe step="main" port="source.in-memory"/>
		</p:input>
	</px:fileset-load>
	<px:assert test-count-min="1" test-count-max="1" error-code="PED01" message="The EPUB must contain exactly one OPF document"
	           name="opf"/>

	<p:for-each>
		<p:iteration-source select="/*/opf:spine/opf:itemref"/>
		<p:variable name="idref" select="/*/@idref"/>
		<p:filter>
			<p:input port="source">
				<p:pipe step="opf" port="result"/>
			</p:input>
			<p:with-option name="select" select="concat('/*/opf:manifest/opf:item[@id=&quot;',$idref,'&quot;]')"/>
		</p:filter>
		<px:assert test-count-min="1" test-count-max="1" error-code="XXX"
		           message="itemref must point at exactly one item"
		           name="opf-item"/>
		<p:sink/>
		<px:fileset-filter>
			<p:input port="source">
				<p:pipe step="source.fileset" port="result"/>
			</p:input>
			<p:with-option name="href" select="/*/resolve-uri(@href,base-uri())">
				<p:pipe step="opf-item" port="result"/>
			</p:with-option>
		</px:fileset-filter>
		<p:choose>
			<p:when test="$ignore-missing='true'">
				<p:identity/>
			</p:when>
			<p:otherwise>
				<px:assert message="Spine item not found: $1" error-code="XXX">
					<p:with-option name="test" select="count(/*/d:file)=1"/>
					<p:with-option name="param1" select="/*/@href">
						<p:pipe step="opf-item" port="result"/>
					</p:with-option>
				</px:assert>
			</p:otherwise>
		</p:choose>
		<p:add-attribute match="/*/d:file[not(@media-type)]" attribute-name="media-type">
			<p:with-option name="attribute-value" select="/*/@media-type">
				<p:pipe step="opf-item" port="result"/>
			</p:with-option>
		</p:add-attribute>
	</p:for-each>

	<px:fileset-join/>

</p:declare-step>
