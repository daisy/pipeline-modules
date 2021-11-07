<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                exclude-result-prefixes="#all">

	<!-- Return a fileset of a DTBook and all the resources referenced from it (i.e. images and PLS lexicons) -->

	<xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

	<xsl:template match="/">
		<xsl:variable name="base" select="base-uri(/*)"/>
		<d:fileset>
			<xsl:attribute name="xml:base" select="replace($base,'[^/]+$','')"/>
			<d:file href="{replace($base,'^.*/([^/]+)$','$1')}" media-type="application/x-dtbook+xml" original-href="{$base}"/>
			<xsl:for-each select="//dtb:link[@rel='pronunciation']/@href">
				<d:file href="{pf:relativize-uri(resolve-uri(.,pf:base-uri(.)),$base)}" original-href="{resolve-uri(.,pf:base-uri(.))}">
					<xsl:if test="../@type">
						<xsl:attribute name="media-type" select="../@type"/>
					</xsl:if>
				</d:file>
			</xsl:for-each>
			<xsl:for-each select="//dtb:*/@src">
				<d:file href="{pf:relativize-uri(resolve-uri(.,pf:base-uri(.)),$base)}" original-href="{resolve-uri(.,pf:base-uri(.))}"/>
			</xsl:for-each>
			<xsl:for-each select="//m:math/@altimg">
				<d:file href="{pf:relativize-uri(resolve-uri(.,pf:base-uri(.)),$base)}" original-href="{resolve-uri(.,pf:base-uri(.))}"/>
			</xsl:for-each>
		</d:fileset>
	</xsl:template>

</xsl:stylesheet>
