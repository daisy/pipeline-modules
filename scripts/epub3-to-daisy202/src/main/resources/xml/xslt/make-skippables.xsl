<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns="http://www.w3.org/ns/SMIL"
                xpath-default-namespace="http://www.w3.org/ns/SMIL"
                exclude-result-prefixes="#all">

	<!--
	    Add 'systemRequired' attribute to par elements that correspond with page numbers.
	-->

	<!--
	    Note that for page numbers to be skippable in EPUB, epub:type="pagebreak" should be present
	    on SMIL elements (see
	    https://www.w3.org/publishing/epub3/epub-mediaoverlays.html#sec-skippability), however we
	    don't use this information in the conversion. We make all page numbers in the DAISY 2.02
	    skippable.
	-->

	<xsl:import href="http://www.daisy.org/pipeline/modules/html-utils/library.xsl"/>

	<xsl:key name="id" match="*[@id]" use="@id"/>
	<xsl:key name="absolute-id" match="*[@id]" use="concat(pf:normalize-uri(pf:html-base-uri(.)),'#',@id)"/>

	<xsl:variable name="page-number-elements" as="element()*">
		<xsl:variable name="page-list" as="document-node(element(d:fileset))?" select="collection()[2]"/>
		<xsl:for-each select="collection()/html:*">
			<xsl:variable name="content-doc" select="."/>
			<xsl:variable name="content-doc-uri" select="pf:normalize-uri(base-uri(.))"/>
			<xsl:for-each select="$page-list//d:file[pf:normalize-uri(resolve-uri(@href,base-uri(.)))=$content-doc-uri]/d:anchor">
				<xsl:sequence select="key('id',@id,$content-doc)"/>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="seq[@epub:textref]">
		<xsl:variable name="absolute-src" select="pf:normalize-uri(pf:resolve-uri(@epub:textref,base-uri(.)))"/>
		<xsl:variable name="referenced-element" as="element()?" select="(collection()/html:*/key('absolute-id',$absolute-src))[1]"/>
		<xsl:choose>
			<xsl:when test="$referenced-element intersect $page-number-elements">
				<xsl:apply-templates mode="pagenumber-on" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="par[text/@src][not(@systemRequired)]">
		<xsl:variable name="absolute-src" select="text/pf:normalize-uri(pf:resolve-uri(@src,base-uri(.)))"/>
		<xsl:variable name="referenced-element" as="element()?" select="(collection()/html:*/key('absolute-id',$absolute-src))[1]"/>
		<xsl:choose>
			<!--
			    In addition to checking for par and seq elements that reference page numbers
			    directly, we also check for par elements that reference descendant elements of page
			    numbers, because we can not be sure that the structure of the content document
			    matches exactly the structure of the media overlay document.
			-->
			<xsl:when test="$referenced-element/ancestor-or-self::* intersect $page-number-elements">
				<xsl:apply-templates mode="pagenumber-on" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="pagenumber-on" match="par[not(@systemRequired)]">
		<xsl:copy>
			<xsl:attribute name="systemRequired" select="'pagenumber-on'"/>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="#default pagenumber-on" match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
