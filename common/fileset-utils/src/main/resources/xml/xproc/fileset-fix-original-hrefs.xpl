<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                exclude-inline-prefixes="#all"
                type="pxi:fileset-fix-original-hrefs" name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Make the original-href attributes reflect what is actually stored on disk.</p>
		<ul>
			<li>Remove original-href attributes of files that do not exist on disk according to @original-href.</li>
			<li>If <code>detect-existing</code> is true, set original-href attributes of files that exist on disk
			according to @href.</li>
			<li>Remove original-href attributes of files that exist in memory.</li>
		</ul>
	</p:documentation>

	<p:input port="source.fileset" primary="true"/>
	<p:input port="source.in-memory" sequence="true">
		<p:empty/>
	</p:input>
	<p:output port="result.fileset" primary="true"/>
	<p:output port="result.in-memory" sequence="true">
		<p:pipe step="in-memory-fileset" port="result.in-memory"/>
	</p:output>

	<p:option name="detect-existing" select="false()" cx:as="xs:boolean">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Whether to set original-href attributes of files that exist on disk according to
			@href. Any existing original-href attributes will be overwritten, so by setting this
			option you prevent that files are being overwritten by other files (but not by in-memory
			documents).</p>
		</p:documentation>
	</p:option>
	<p:option name="fail-on-missing" select="false()" cx:as="xs:boolean">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Whether to raise an error for files that are neither on disk or exist in memory.</p>
		</p:documentation>
	</p:option>
	<p:option name="purge" select="false()" cx:as="xs:boolean">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Whether to remove files that are neither on disk or exist in memory.</p>
		</p:documentation>
	</p:option>

	<p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
		<p:documentation>
			px:message
			px:error
		</p:documentation>
	</p:import>
	<p:import href="fileset-join.xpl">
		<p:documentation>
			px:fileset-join
		</p:documentation>
	</p:import>
	<p:import href="fileset-filter-in-memory.xpl">
		<p:documentation>
			px:fileset-filter-in-memory
		</p:documentation>
	</p:import>
	<cx:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl" type="application/xslt+xml">
		<p:documentation>
			pf:file-exists
		</p:documentation>
	</cx:import>

	<px:fileset-filter-in-memory name="in-memory-fileset">
		<p:documentation>Also normalizes @href</p:documentation>
		<p:input port="source.in-memory">
			<p:pipe step="main" port="source.in-memory"/>
		</p:input>
	</px:fileset-filter-in-memory>
	<p:sink/>

	<p:identity>
		<p:input port="source">
			<p:pipe step="main" port="source.fileset"/>
		</p:input>
	</p:identity>
	<p:choose>
		<p:when test="/*/@xml:base">
			<!--
			    FIXME: make xml:base absolute because if it is relative the p:delete below will mess
			    things up for some reason (Calabash bug?)
			-->
			<p:add-xml-base/>
		</p:when>
		<p:otherwise>
			<p:identity/>
		</p:otherwise>
	</p:choose>

	<px:fileset-join name="source.fileset">
		<p:documentation>Normalize @href and @original-href</p:documentation>
	</px:fileset-join>
	
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
				<p:variable name="href-on-disk" cx:as="xs:boolean"
				            select="$detect-existing and pf:file-exists(replace($href,'^(jar|bundle):',''))"/>
				<p:choose>
					<p:when test="$detect-existing">
						<p:identity px:message="File at {$href} {if ($href-on-disk) then 'exists' else 'does not exist'}"
						            px:message-severity="DEBUG"/>
					</p:when>
					<p:otherwise>
						<p:identity/>
					</p:otherwise>
				</p:choose>
				<p:choose>
					<p:documentation>Else if href exists on disk, set original-href</p:documentation>
					<p:when test="$href-on-disk">
						<p:add-attribute match="/*" attribute-name="original-href">
							<p:with-option name="attribute-value" select="$href"/>
						</p:add-attribute>
					</p:when>
					<p:when test="$original-href!=''">
						<p:variable name="original-href-on-disk" cx:as="xs:boolean"
						            select="pf:file-exists(replace($original-href,'^(jar|bundle):',''))"/>
						<p:identity px:message="File at {$original-href} {if ($original-href-on-disk) then 'exists' else 'does not exist'}"
						            px:message-severity="DEBUG"/>
						<p:choose>
							<p:documentation>
								Else if it does not exist on disk, remove original-href or remove file if purge is set.
							</p:documentation>
							<p:when test="not($original-href-on-disk)">
								<p:variable name="message"
								            select="concat('Found document in fileset that was declared as being on disk ',
								                           'but was neither stored on disk nor in memory: ', $original-href)"/>
								<p:choose>
									<p:when test="$fail-on-missing">
										<px:error code="PEZE01">
											<p:with-option name="message" select="$message"/>
										</px:error>
									</p:when>
									<p:when test="$purge">
										<p:identity>
											<p:input port="source">
												<p:empty/>
											</p:input>
										</p:identity>
										<px:message severity="WARN">
											<p:with-option name="message" select="$message"/>
										</px:message>
									</p:when>
									<p:otherwise>
										<px:message severity="WARN">
											<p:with-option name="message" select="$message"/>
										</px:message>
										<p:delete match="@original-href"/>
									</p:otherwise>
								</p:choose>
							</p:when>
							<p:otherwise>
								<p:identity/>
							</p:otherwise>
						</p:choose>
					</p:when>
					<p:otherwise>
						<p:documentation>File does not exist. Remove it if purge is set.</p:documentation>
						<p:variable name="message"
						            select="concat('Found document in fileset that is neither stored on disk nor in memory: ', $href)"/>
						<p:choose>
							<p:when test="$fail-on-missing">
								<px:error code="PEZE00">
									<p:with-option name="message" select="$message"/>
								</px:error>
							</p:when>
							<p:when test="$purge">
								<p:identity>
									<p:input port="source">
										<p:empty/>
									</p:input>
								</p:identity>
								<px:message severity="WARN">
									<p:with-option name="message" select="$message"/>
								</px:message>
							</p:when>
							<p:otherwise>
								<px:message severity="WARN">
									<p:with-option name="message" select="$message"/>
								</px:message>
							</p:otherwise>
						</p:choose>
					</p:otherwise>
				</p:choose>
			</p:otherwise>
		</p:choose>
	</p:viewport>

</p:declare-step>
