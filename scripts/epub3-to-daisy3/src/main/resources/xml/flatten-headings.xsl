<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="#all">

	<xsl:include href="http://www.daisy.org/pipeline/modules/common-utils/generate-id.xsl"/>

	<xsl:key name="original-id" match="d:anchor" use="string(@original-id)"/>

	<xsl:template match="/" priority="1">
		<xsl:call-template name="pf:next-match-with-generated-ids">
			<xsl:with-param name="prefix" select="'heading_'"/>
			<xsl:with-param name="for-elements" select="//levelhd[not(@id)]|
			                                            //hd[not(@id)]|
			                                            //h1[not(@id)]|
			                                            //h2[not(@id)]|
			                                            //h3[not(@id)]|
			                                            //h4[not(@id)]|
			                                            //h5[not(@id)]|
			                                            //h6[not(@id)]"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/">
		<!--
		    Mapping from IDs of unwrapped elements to IDs of their parent heading elements, as a set of
		    d:anchor elements. (Note that there may be d:anchor with the same @id and different
		    @original-id.)
		-->
		<xsl:variable name="id-mapping">
			<xsl:document>
				<d:file>
					<xsl:apply-templates mode="id-mapping" select="*"/>
				</d:file>
			</xsl:document>
		</xsl:variable>
		<!--
		    update idref of clips
		-->
		<xsl:variable name="audio-clips" as="element(d:audio-clips)">
			<xsl:for-each select="collection()[2]/*">
				<xsl:copy>
					<xsl:sequence select="@*"/>
					<xsl:for-each select="d:clip">
						<xsl:copy>
							<xsl:sequence select="@* except @idref"/>
							<xsl:variable name="anchor" as="element(d:anchor)?" select="key('original-id',@idref,$id-mapping)"/>
							<xsl:choose>
								<xsl:when test="exists($anchor)">
									<xsl:attribute name="idref" select="$anchor/@id"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="@idref"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:copy>
					</xsl:for-each>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<!--
		    merge clips with same idref
		-->
		<xsl:variable name="audio-clips" as="element(d:audio-clips)">
			<xsl:for-each select="$audio-clips">
				<xsl:copy>
					<xsl:sequence select="@*"/>
					<xsl:for-each-group select="d:clip" group-by="@idref">
						<xsl:variable name="clips" as="element(d:clip)*" select="current-group()"/>
						<xsl:choose>
							<xsl:when test="count($clips)=1">
								<xsl:sequence select="$clips"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="clips" as="element(d:clip)*">
									<xsl:perform-sort select="$clips">
										<xsl:sort select="@clipBegin"/>
									</xsl:perform-sort>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="every $i in 1 to count($clips) - 1
									                satisfies $clips[$i]/@src=$clips[$i + 1]/@src
									                          and $clips[$i]/@clipEnd=$clips[$i + 1]/@clipBegin">
										<d:clip idref="{$clips[1]/@idref}"
										        src="{$clips[1]/@src}"
										        clipBegin="{$clips[1]/@clipBegin}"
										        clipEnd="{$clips[last()]/@clipEnd}"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:message terminate="yes"
										             select="concat(
										                       'Audio clips of a heading element can not be combined: ',
										                       string-join($clips/concat(@src,' (',@clipBegin,'-',@clipEnd,')'),', '))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each-group>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<xsl:apply-templates select="/*">
			<xsl:with-param name="id-mapping" tunnel="yes" select="$id-mapping"/>
		</xsl:apply-templates>
		<xsl:result-document href="mapping">
			<xsl:sequence select="$audio-clips"/>
		</xsl:result-document>
	</xsl:template>

	<!--
	    these are the heading elements that navPoint are created from in px:daisy3-create-ncx
	-->
	<xsl:template match="levelhd|hd|h1|h2|h3|h4|h5|h6">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:if test="not(@id)">
				<xsl:call-template name="pf:generate-id"/>
			</xsl:if>
			<xsl:apply-templates mode="flatten"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="a/@href[starts-with(.,'#')]">
		<xsl:param name="id-mapping" tunnel="yes" required="yes"/>
		<xsl:variable name="anchor" as="element(d:anchor)?" select="key('original-id',substring(.,2),$id-mapping)"/>
		<xsl:choose>
			<xsl:when test="exists($anchor)">
				<xsl:attribute name="href" select="concat('#',$anchor/@id)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="flatten" match="*" priority="1">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>

	<xsl:template mode="#default flatten" match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="id-mapping" match="*">
		<xsl:apply-templates mode="#current" select="*"/>
	</xsl:template>

	<xsl:template mode="id-mapping" match="levelhd|hd|h1|h2|h3|h4|h5|h6">
		<xsl:variable name="id" as="xs:string">
			<xsl:choose>
				<xsl:when test="@id">
					<xsl:sequence select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="pf:generate-id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select=".//*[@id]">
			<d:anchor original-id="{@id}" id="{$id}"/>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>

