<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    name="main" exclude-inline-prefixes="#all"
    type="pxi:text-to-ssml-wrapper">

  <p:import href="../../main/resources/xml/xproc/styled-text-to-ssml.xpl"/>
  <p:import href="clean-text.xpl"/>

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:option name="with-lexicons" required="false" select="'false'"/>
  <p:option name="sheet-uri" required="false" select="''"/>

  <p:choose name="lexicons-uris">
    <p:when test="$with-lexicons = 'true'">
      <p:output port="result"/>
      <p:identity>
	<p:input port="source">
	  <p:inline>
	    <ssml:speak version="1.0"
			xmlns="http://www.w3.org/2001/10/synthesis"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.w3.org/2001/10/synthesis
					    http://www.w3.org/TR/speech-synthesis/synthesis.xsd">
	      <ssml:lexicon href="../resources/lexicon-test-en.pls"/>
	      <ssml:lexicon href="../resources/lexicon-test-fr.pls"/>
	    </ssml:speak>
	  </p:inline>
	</p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:output port="result">
	<p:inline>
	  <ssml:speak/>
	</p:inline>
      </p:output>
      <p:sink/>
    </p:otherwise>
  </p:choose>

  <px:styled-text-to-ssml>
    <p:input port="content.in">
      <p:pipe port="source" step="main"/>
    </p:input>
    <p:input port="fileset.in">
      <p:empty/>
    </p:input>
    <p:input port="config">
      <p:pipe port="result" step="lexicons-uris"/>
    </p:input>
    <p:with-option name="section-elements" select="'level,section'"/>
    <p:with-option name="first-sheet-uri" select="$sheet-uri"/>
    <p:with-option name="style-ns" select="'http://www.daisy.org/ns/pipeline/tmp'"/>
  </px:styled-text-to-ssml>

  <p:wrap-sequence wrapper="all" wrapper-namespace="http://www.w3.org/2001/10/synthesis"/>

  <!-- Clean the text nodes because the conversion to SSML may add punctuation marks and white spaces. -->
  <pxi:clean-text/>
</p:declare-step>
