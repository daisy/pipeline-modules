<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::span|self::div|self::a|self::hr]
	                      [@epub:type/tokenize(.,'\s+')='pagebreak']
	                      [not(*)]">
		<span>
			<xsl:apply-templates select="@* except (@class|@epub:type)"/>
			<xsl:variable name="value" as="text()">
				<xsl:choose>
					<xsl:when test="normalize-space(string(.))">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@title"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="types" as="xs:string*" select="@epub:type/tokenize(.,'\s+')[not(.='')]"/>
			<xsl:variable name="classes" as="xs:string*" select="@class/tokenize(.,'\s+')[not(.='')]"/>
			<xsl:variable name="classes" as="xs:string*">
				<xsl:sequence select="$classes"/>
				<xsl:choose>
					<xsl:when test="$classes=('page-normal','page-front','page-special')"/>
					<xsl:when test="matches(string($value),'^[0-9]+$')">
						<xsl:sequence select="'page-normal'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="'page-special'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="class" select="string-join($classes,' ')"/>
			<xsl:if test="count($types) &gt; 1">
				<xsl:attribute name="epub:type" select="string-join($types[not(.='pagebreak')],' ')"/>
			</xsl:if>
			<xsl:sequence select="$value"/>
		</span>
	</xsl:template>

</xsl:stylesheet>
