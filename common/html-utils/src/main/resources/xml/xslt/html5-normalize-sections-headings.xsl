<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">

	<xsl:param name="fix-heading-ranks" required="yes"/> <!-- keep | outline-depth -->
	<xsl:param name="fix-sectioning" required="yes"/>    <!-- keep | outline-depth | no-implied -->

	<!--
	    * d:outline correspond with body|article|aside|nav|section
	    * d:section correspond with fragments of body|article|aside|nav|section
	    * d:section with d:section parent/preceding-sibling correspond with implied sections
	    
	    * a d:outline has a @owner (body|article|aside|nav|section element)
	    * a d:outline has only d:section children
	    * a d:outline has at least one child
	    * a d:section that is the first child of a d:outline has a @owner (the same as the d:outline)
	    * a d:section may have d:outline or d:section children
	    * a d:section may have zero children
	    * a d:section that is the child of a d:section has only d:section children
	    * a d:section that is not a first child has a @heading
	    * a d:section that is the child of a d:section has a @heading
	-->
	<xsl:variable name="root-outline" select="collection()/d:outline"/>

	<xsl:key name="heading" match="d:section[@heading]" use="@heading"/>

	<xsl:template match="*[@id=$root-outline/@owner]"> <!-- body -->
		<xsl:variable name="body" as="element()">
			<xsl:choose>
				<xsl:when test="$fix-heading-ranks='outline-depth'">
					<xsl:apply-templates mode="rename-headings" select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="$body">
			<xsl:choose>
				<xsl:when test="$fix-sectioning=('outline-depth','no-implied')">
					<xsl:apply-templates mode="wrap-implied-sections" select="$root-outline">
						<xsl:with-param name="sectioning-element" select="."/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="wrap-implied-sections" match="d:outline">
		<xsl:param name="sectioning-element" as="element()" required="yes"/> <!-- body|article|aside|nav|section -->
		<xsl:variable name="sections" as="element(d:section)*" select="*"/> <!-- d:section+ -->
		<xsl:variable name="implied-sections" as="element(d:section)*" select="$sections[position()>1]"/>
		<xsl:variable name="section-boundaries" as="xs:string*" select="$implied-sections/@heading"/>
		<xsl:choose>
			<xsl:when test="$fix-sectioning='no-implied'">
				<xsl:for-each-group select="$sectioning-element/node()" group-starting-with="*[@id=$section-boundaries]">
					<xsl:variable name="i" select="position()"/>
					<xsl:variable name="fragment" select="current-group()"/>
					<xsl:for-each select="$sectioning-element">
						<xsl:copy>
							<xsl:sequence select="@* except @id"/>
							<xsl:if test="$i=1">
								<xsl:sequence select="@id"/>
							</xsl:if>
							<xsl:apply-templates mode="#current" select="$sections[$i]">
								<xsl:with-param name="fragment" select="$fragment"/>
							</xsl:apply-templates>
						</xsl:copy>
					</xsl:for-each>
				</xsl:for-each-group>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$sectioning-element">
					<xsl:copy>
						<xsl:sequence select="@*"/>
						<xsl:for-each-group select="node()" group-starting-with="*[@id=$section-boundaries]">
							<xsl:variable name="i" select="position()"/>
							<xsl:apply-templates mode="#current" select="$sections[$i]">
								<xsl:with-param name="fragment" select="current-group()"/>
							</xsl:apply-templates>
						</xsl:for-each-group>
					</xsl:copy>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="wrap-implied-sections" match="d:section">
		<xsl:param name="fragment" as="node()*" required="yes"/>
		<xsl:choose>
			<xsl:when test="not(exists(d:section|d:outline))">
				<xsl:sequence select="$fragment"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="sections" as="element()*" select="d:section|d:outline"/>
				<xsl:variable name="starting-with-outline" select="$fragment[1]/@id=$sections[self::d:outline]/@owner"/>
				<xsl:variable name="starting-with-implied-section" select="$fragment[1]/@id=$sections[self::d:section]/@heading"/>
				<xsl:for-each-group select="$fragment" group-starting-with="*[@id=$sections[self::d:outline]/@owner]|
				                                                            *[@id=$sections[self::d:section]/@heading]">
					<xsl:variable name="i" select="position()"/>
					<xsl:choose>
						<xsl:when test="$i=1 and not($starting-with-implied-section or $starting-with-outline)">
							<xsl:sequence select="current-group()"/>
						</xsl:when>
						<xsl:when test="current()/@id=$sections[self::d:outline]/@owner">
							<xsl:apply-templates mode="#current"
							                     select="if ($starting-with-implied-section or $starting-with-outline)
							                             then $sections[$i]
							                             else $sections[$i - 1]">
								<xsl:with-param name="sectioning-element" select="current()"/>
							</xsl:apply-templates>
							<xsl:sequence select="current-group() except current()"/>
						</xsl:when>
						<xsl:otherwise>
							<section>
								<xsl:apply-templates mode="#current"
								                     select="if ($starting-with-implied-section or $starting-with-outline)
								                             then $sections[$i]
								                             else $sections[$i - 1]">
									<xsl:with-param name="fragment" select="current-group()"/>
								</xsl:apply-templates>
							</section>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each-group>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="rename-headings" match="h1|h2|h3|h4|h5|h6|hgroup">
		<xsl:if test="not(exists(@id))">
			<xsl:message terminate="yes">coding error</xsl:message>
		</xsl:if>
		<xsl:variable name="section" as="element(d:section)?" select="key('heading',@id,$root-outline)[1]"/>
		<xsl:if test="not($section)">
			<xsl:message terminate="yes">coding error</xsl:message>
		</xsl:if>
		<xsl:variable name="outline-depth" as="xs:integer" select="min((6,count($section/ancestor-or-self::d:section)))"/>
		<xsl:choose>
			<xsl:when test="self::hgroup">
				<xsl:sequence select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="h{$outline-depth}">
					<xsl:sequence select="@*|node()"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="#default rename-headings" match="@*|node()">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:apply-templates mode="#current"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
