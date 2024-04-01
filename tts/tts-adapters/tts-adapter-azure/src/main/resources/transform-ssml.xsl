<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/2001/10/synthesis"
                xpath-default-namespace="http://www.w3.org/2001/10/synthesis"
                exclude-result-prefixes="#all">

	<xsl:output omit-xml-declaration="yes"/>

	<xsl:param name="voice" required="yes" as="xs:string"/>

	<!--
	    Format the SSML according to the Cognitive Speech service's rules:
	    https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/speech-synthesis-markup-structure
	-->

	<xsl:template match="*">
		<speak version="1.0">
			<xsl:sequence select="/*/@xml:lang"/>
			<!-- xml:lang will normally be present on <s> elements, but we don't assume this is always the case -->
			<xsl:if test="not(/*/@xml:lang)">
				<xsl:attribute name="xml:lang" select="'und'"/>
			</xsl:if>
			<voice name="{$voice}">
				<xsl:apply-templates mode="copy" select="."/>
				<break time="250ms"/>
			</voice>
		</speak>
	</xsl:template>

	<xsl:template mode="copy" match="speak">
		<xsl:apply-templates mode="#current" select="node()"/>
	</xsl:template>

	<xsl:template mode="copy" match="prosody/@rate">
		<xsl:variable name="rate" as="xs:string" select="normalize-space(string(.))"/>
		<xsl:variable name="rate" as="xs:string">
			<xsl:choose>
				<xsl:when test="matches($rate,'^[0-9]+$')">
					<!--
					    Azure interprets an absolute number as a relative value (see
					    https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-synthesis-markup-voice#adjust-prosody)
					    so divide by the "normal" rate of 200 words per minute (see
					    https://www.w3.org/TR/CSS2/aural.html#voice-char-props).
					-->
					<xsl:sequence select="format-number(number($rate) div 200,'0.00')"/>
				</xsl:when>
				<xsl:when test="matches($rate,'^[0-9]+%$')">
					<!--
					    Azure interprets a percentage as a relative change (see
					    https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-synthesis-markup-voice#adjust-prosody),
					    so convert to number without percentage.
					-->
					<xsl:sequence select="format-number(number(substring($rate,1,string-length($rate)-1)) div 100,'0.00')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$rate"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:attribute name="{name(.)}" select="$rate"/>
	</xsl:template>

	<!-- rename mark to bookmark: not needed: regular SSML marks also supported -->
	<!--
	<xsl:template mode="copy" match="mark">
		<bookmark>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</bookmark>
	</xsl:template>

	<xsl:template mode="copy" match="mark/@name">
		<xsl:attribute name="mark" select="string(.)"/>
	</xsl:template>
	-->

	<!-- unwrap token -->
	<xsl:template mode="copy" match="token">
		<xsl:apply-templates mode="#current" select="node()"/>
	</xsl:template>

	<xsl:template mode="copy" match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
