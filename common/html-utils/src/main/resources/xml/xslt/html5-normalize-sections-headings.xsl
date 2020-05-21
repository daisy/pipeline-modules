<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
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
		<xsl:variable name="fragment" as="node()*" select="$sectioning-element/node()"/>
		<xsl:variable name="sections" as="element(d:section)+" select="*"/>
		<xsl:variable name="outline" as="node()*">
			<xsl:iterate select="$sections">
				<xsl:param name="remaining-content" as="node()*" select="$fragment"/>
				<xsl:variable name="next-section" as="element(d:section)?" select="following-sibling::*[1]"/>
				<xsl:variable name="split-before" as="element()?" select="$remaining-content[@id=$next-section/@heading]"/>
				<xsl:apply-templates mode="#current" select=".">
					<xsl:with-param name="fragment" select="$remaining-content except $split-before/(self::*,following::node())"/>
					<xsl:with-param name="copy-parent-element" select="$fix-sectioning='no-implied'"/>
					<xsl:with-param name="wrapper-element" select="()"/>
				</xsl:apply-templates>
				<xsl:choose>
					<xsl:when test="$split-before">
						<xsl:next-iteration>
							<xsl:with-param name="remaining-content"
							                select="$remaining-content except $split-before/preceding::node()"/>
						</xsl:next-iteration>
					</xsl:when>
					<xsl:otherwise>
						<xsl:break/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:iterate>
		</xsl:variable>
		<xsl:call-template name="wrap">
			<xsl:with-param name="content" select="$outline"/>
			<xsl:with-param name="wrapper-elements" select="if ($fix-sectioning='no-implied')
			                                                then ()
			                                                else $sectioning-element"/>
			<xsl:with-param name="copy-id-attribute" select="true()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="wrap-implied-sections" match="d:section">
		<!-- The nodes belonging to this section. -->
		<xsl:param name="fragment" as="node()*" required="yes"/>
		<!-- Whether to wrap the fragment in the original parent element. -->
		<xsl:param name="copy-parent-element" as="xs:boolean" required="yes"/>
		<!-- If specified, use this sectioning element to wrap the fragment. -->
		<xsl:param name="wrapper-element" as="element()?" required="yes"/>
		<xsl:variable name="section" as="node()*">
			<xsl:variable name="subsections" as="element()*" select="*"/> <!-- element(d:section|d:outline)* -->
			<xsl:variable name="first-subsection" as="element()?" select="$subsections[1]"/>
			<xsl:variable name="split-before" as="element()?" select="$fragment[@id=$first-subsection/(@owner,@heading)[1]]"/>
			<xsl:sequence select="$fragment except $split-before/(self::*,following::node())"/>
			<xsl:if test="exists($split-before)">
				<xsl:iterate select="$subsections">
					<xsl:param name="remaining-content" as="node()*" select="$fragment except $split-before/preceding::node()"/>
					<xsl:variable name="next-section" as="element()?" select="following-sibling::*[1]"/>
					<xsl:variable name="split-before" as="element()?"
					              select="$remaining-content[@id=$next-section/(@owner,@heading)[1]]"/>
					<xsl:choose>
						<xsl:when test="@owner">
							<!-- first node is sectioning element -->
							<xsl:apply-templates mode="#current" select=".">
								<xsl:with-param name="sectioning-element" select="$remaining-content[1]"/>
							</xsl:apply-templates>
							<xsl:sequence select="$remaining-content
							                      except ($remaining-content[1],$split-before/(self::*,following::node()))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates mode="#current" select=".">
								<xsl:with-param name="fragment"
								                select="$remaining-content except $split-before/(self::*,following::node())"/>
								<xsl:with-param name="copy-parent-element" select="false()"/>
								<xsl:with-param name="wrapper-element" select="$generated-sectioning-element"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$split-before">
							<xsl:next-iteration>
								<xsl:with-param name="remaining-content"
								                select="$remaining-content except $split-before/preceding::node()"/>
							</xsl:next-iteration>
						</xsl:when>
						<xsl:otherwise>
							<xsl:break/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:iterate>
			</xsl:if>
		</xsl:variable>
		<xsl:call-template name="wrap">
			<xsl:with-param name="content" select="$section"/>
			<xsl:with-param name="wrapper-elements" select="(if ($copy-parent-element) then $fragment[1]/parent::* else (),
			                                                 $wrapper-element)"/>
			<xsl:with-param name="copy-id-attribute"
			                select="if ($copy-parent-element)
			                        then not(exists($fragment[1]/parent::*/child::node() intersect $fragment[1]/preceding::*))
			                        else ()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="wrap">
		<xsl:param name="content" as="node()*" required="yes"/>
		<!-- wrapper elements, from outer to inner -->
		<xsl:param name="wrapper-elements" as="element()*" required="yes"/>
		<xsl:param name="copy-id-attribute" as="xs:boolean*" required="yes"/>
		<xsl:choose>
			<xsl:when test="exists($wrapper-elements)">
				<xsl:copy select="$wrapper-elements[1]">
					<xsl:sequence select="@* except @id"/>
					<xsl:if test="$copy-id-attribute[1]">
						<xsl:sequence select="@id"/>
					</xsl:if>
					<xsl:call-template name="wrap">
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="wrapper-elements" select="$wrapper-elements[position()&gt;1]"/>
						<xsl:with-param name="copy-id-attribute" select="$copy-id-attribute[position()&gt;1]"/>
					</xsl:call-template>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="generated-sectioning-element" as="element()">
		<section/>
	</xsl:variable>

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
