<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                exclude-inline-prefixes="#all"
                type="pxi:fileset-fix-original-hrefs" name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Make the original-href attributes reflect what is actually stored on disk.</p>
		<ul>
			<li>Remove original-href attributes of files that do not exist on disk according to @original-href.</li>
			<li>Set original-href attributes of files that exist on disk according to @href.</li>
			<li>Remove original-href attributes of files that exist in memory.</li>
		</ul>
	</p:documentation>

	<p:input port="source.fileset" primary="true"/>
	<p:input port="source.in-memory" sequence="true">
		<p:empty/>
	</p:input>
	<p:output port="result.fileset"/>

	<p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
		<p:documentation>
			px:info
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl">
		<p:documentation>
			px:unzip
		</p:documentation>
	</p:import>
	<p:import href="fileset-filter-in-memory.xpl">
		<p:documentation>
			px:fileset-filter-in-memory
		</p:documentation>
	</p:import>

	<p:declare-step type="pxi:file-on-disk">
		<p:documentation>
			Return &lt;c:result&gt;true&lt;/c:result&gt; if file at "href" exists on disk. Also
			works for zipped files.
		</p:documentation>
		<p:option name="href" required="true"/>
		<p:input port="source"/>
		<p:output port="result" primary="true">
			<p:pipe step="source" port="result"/>
		</p:output>
		<p:output port="on-disk">
			<p:pipe step="on-disk" port="result"/>
		</p:output>
		<p:identity name="source"/>
		<p:sink/>
		<p:try>
			<p:group>
				<px:info>
					<p:with-option name="href" select="replace($href,'^([^!]+)(!/.+)?$','$1')"/>
				</px:info>
				<p:choose>
					<p:when test="contains($href,'!/')">
						<px:unzip>
							<p:with-option name="href" select="replace($href,'^([^!]+)!/(.+)$','$1')"/>
						</px:unzip>
						<p:filter>
							<p:with-option name="select"
							               select="concat(
							                        '/c:zipfile/c:file[@name=&quot;',
							                        replace($href,'^([^!]+)!/(.+)$','$2'),
							                        '&quot;]')"/>
						</p:filter>
					</p:when>
					<p:otherwise>
						<p:identity/>
					</p:otherwise>
				</p:choose>
				<p:count/>
			</p:group>
			<p:catch>
				<!-- FIXME: only catch error with code "err:FU01" -->
				<p:identity>
					<p:input port="source">
						<p:inline>
							<c:result>0</c:result>
						</p:inline>
					</p:input>
				</p:identity>
			</p:catch>
		</p:try>
		<p:string-replace match="/c:result/text()" replace="if (string(.)='0') then 'false' else 'true'"/>
		<p:group>
			<p:variable name="on-disk" select="string(/*)"/>
			<p:identity px:message="File at {$href} {if ($on-disk='true') then 'exists' else 'does not exist'}"
			            px:message-severity="DEBUG"/>
		</p:group>
		<p:identity name="on-disk"/>
	</p:declare-step>

	<px:fileset-filter-in-memory name="in-memory-fileset">
		<p:input port="source.in-memory">
			<p:pipe step="main" port="source.in-memory"/>
		</p:input>
	</px:fileset-filter-in-memory>
	<p:sink/>

	<!--
	    FIXME: make xml:base absolute because if it is relative the p:delete below will mess things
	    up for some reason (Calabash bug?)
	-->
	<p:add-xml-base>
		<p:input port="source">
			<p:pipe step="main" port="source.fileset"/>
		</p:input>
	</p:add-xml-base>
	
	<p:documentation>Delete original-href that equal href</p:documentation>
	<p:delete match="d:file/@original-href[resolve-uri(.,base-uri(.))=parent::*/@href/resolve-uri(.,base-uri(.))]"/>

	<p:viewport match="/*/d:file">
		<p:variable name="href" select="/*/@href/resolve-uri(.,base-uri(.))"/>
		<p:variable name="original-href" select="/*/@original-href/resolve-uri(.,base-uri(.))"/>
		<p:choose>
			<p:xpath-context>
				<p:pipe step="in-memory-fileset" port="result"/>
			</p:xpath-context>
			<p:documentation>Remove original-href if file exists in memory</p:documentation>
			<p:when test="//d:file/@href[resolve-uri(.,base-uri(.))=$href]">
				<p:delete match="@original-href"/>
			</p:when>
			<p:otherwise>
				<pxi:file-on-disk name="href-on-disk">
					<p:with-option name="href" select="$href"/>
				</pxi:file-on-disk>
				<p:choose>
					<p:xpath-context>
						<p:pipe step="href-on-disk" port="on-disk"/>
					</p:xpath-context>
					<p:documentation>Else if href exists on disk, set original-href</p:documentation>
					<p:when test="string(/*)='true'">
						<p:add-attribute match="/*" attribute-name="original-href">
							<p:with-option name="attribute-value" select="$href"/>
						</p:add-attribute>
					</p:when>
					<p:when test="$original-href!=''">
						<pxi:file-on-disk name="original-href-on-disk">
							<p:with-option name="href" select="$original-href"/>
						</pxi:file-on-disk>
						<p:choose>
							<p:xpath-context>
								<p:pipe step="original-href-on-disk" port="on-disk"/>
							</p:xpath-context>
							<p:documentation>Else if it does not exist on disk, remove original-href</p:documentation>
							<p:when test="not(string(/*)='true')">
								<p:delete match="@original-href"/>
							</p:when>
							<p:otherwise>
								<p:identity/>
							</p:otherwise>
						</p:choose>
					</p:when>
					<p:otherwise>
						<p:identity/>
					</p:otherwise>
				</p:choose>
			</p:otherwise>
		</p:choose>
	</p:viewport>

</p:declare-step>
