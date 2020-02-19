<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:d="http://www.daisy.org/ns/pipeline/data">
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>
	
	<xsl:variable name="css.fileset" select="collection()[2]"/>
	<xsl:variable name="html" select="collection()[position() &gt; 2]"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
	    Update dcterms:modified
	-->
	<xsl:template match="opf:metadata/opf:meta[@property='dcterms:modified']">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:value-of select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H')),
			                                      '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="opf:metadata/opf:meta[@name='dcterms:modified']">
		<xsl:copy>
			<xsl:sequence select="@* except @content"/>
			<xsl:attribute name="content"
			               select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H')),
			                                      '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
	    Update dc:language
	-->
	<xsl:template match="opf:metadata/dc:language"/>
	<xsl:template match="opf:metadata">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="distinct-values($html//@xml:lang)">
				<dc:language>
					<xsl:value-of select="."/>
				</dc:language>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	<!--
	    Add CSS files
	-->
	<xsl:template match="opf:manifest">
		<xsl:variable name="ids" as="xs:string*">
			<xsl:call-template name="generate-ids">
				<xsl:with-param name="amount" select="count($css.fileset//d:file)"/>
				<xsl:with-param name="prefix" tunnel="yes" select="'item_'"/>
				<xsl:with-param name="in-use" tunnel="yes" select="opf:item/@id"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="output-base-uri" select="base-uri(/*)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="$css.fileset//d:file">
				<xsl:variable name="i" select="position()"/>
				<xsl:element name="item" xmlns="http://www.idpf.org/2007/opf">
					<xsl:attribute name="href" select="pf:relativize-uri(
					                                     resolve-uri(@href,base-uri(.)),
					                                     $output-base-uri)"/>
					<xsl:attribute name="id" select="$ids[$i]"/>
					<xsl:attribute name="media-type" select="'text/css'"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="generate-ids">
		<xsl:param name="amount" as="xs:integer" required="yes"/>
		<xsl:param name="prefix" as="xs:string" tunnel="yes" required="yes"/>
		<xsl:param name="in-use" as="xs:string*" tunnel="yes" select="()"/>
		<xsl:param name="_feed" as="xs:integer" select="1"/>
		<xsl:variable name="id" select="concat($prefix,$_feed)"/>
		<xsl:choose>
			<xsl:when test="$id=$in-use">
				<xsl:call-template name="generate-ids">
					<xsl:with-param name="amount" select="$amount"/>
					<xsl:with-param name="_feed" select="$_feed + 1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$id"/>
				<xsl:if test="$amount &gt; 1">
					<xsl:call-template name="generate-ids">
						<xsl:with-param name="amount" select="$amount - 1"/>
						<xsl:with-param name="_feed" select="$_feed + 1"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
