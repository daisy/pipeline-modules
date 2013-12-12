<p:declare-step type="px:break-and-reshape"
		version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
		exclude-inline-prefixes="#all">

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="break-detect.xpl"/>

  <p:option name="can-contain-sentences" required="false" select="''"/>
  <p:option name="can-contain-subsentences" required="true"/>
  <p:option name="ignored-elements" required="false" select="''"/>
  <p:option name="inline-tags" required="true"/>
  <p:option name="output-word-tag" required="true"/>
  <p:option name="output-sentence-tag" required="true"/>
  <p:option name="word-attr" required="false" select="''"/>
  <p:option name="word-attr-val" required="false" select="''"/>
  <p:option name="sentence-attr" required="false" select="''"/>
  <p:option name="sentence-attr-val" required="false" select="''"/>
  <p:option name="output-ns" required="true"/>
  <!-- TODO: option "can-contain-words" -->

  <!-- Force the Lexer to create new words or new sentences -->
  <!-- when the following elements are detected: -->
  <p:option name="ensure-word-before" required="false" select="''"/>
  <p:option name="ensure-word-after" required="false" select="''"/>
  <p:option name="ensure-sentence-before" required="false" select="''"/>
  <p:option name="ensure-sentence-after" required="false" select="''"/>

  <!-- If $split-skippable is enable, the script will wrap the nodes around $skippable-tags -->
  <!-- with a node of type $output-subsentence-tag. -->
  <!-- The standard must allow $output-subsentence-tag to have an ID -->
  <p:option name="split-skippable" required="false" select="'false'"/>
  <p:option name="skippable-tags" required="false" select="''"/>
  <p:option name="output-subsentence-tag" required="true"/>

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>
  <p:output port="sentence-ids">
    <p:pipe port="secondary" step="create-valid"/>
  </p:output>

  <p:variable name="tmp-ns" select="'http://www.daisy.org/ns/pipeline/tmp'"/>
  <p:variable name="tmp-word-tag" select="'w'"/>
  <p:variable name="tmp-sentence-tag" select="'s'"/>

  <!-- run the java-based lexing step -->
  <px:break-detect name="break">
    <p:with-option name="inline-tags" select="$inline-tags"/>
    <p:with-option name="output-word-tag" select="$tmp-word-tag"/>
    <p:with-option name="output-sentence-tag" select="$tmp-sentence-tag"/>
    <p:with-option name="tmp-ns" select="$tmp-ns"/>
    <p:with-option name="ensure-word-before" select="$ensure-word-before"/>
    <p:with-option name="ensure-word-after" select="$ensure-word-after"/>
    <p:with-option name="ensure-sentence-before" select="$ensure-word-before"/>
    <p:with-option name="ensure-sentence-after" select="$ensure-sentence-after"/>
  </px:break-detect>
  <cx:message message="java-based break detection done"/>

  <!-- create the actual sentence/words element -->
  <p:xslt name="create-valid">
    <p:with-param name="can-contain-sentences" select="$can-contain-sentences"/>
    <p:with-param name="ignored-elements" select="$ignored-elements"/>
    <p:with-param name="tmp-word-tag" select="$tmp-word-tag"/>
    <p:with-param name="tmp-sentence-tag" select="$tmp-sentence-tag"/>
    <p:with-param name="output-word-tag" select="$output-word-tag"/>
    <p:with-param name="output-sentence-tag" select="$output-sentence-tag"/>
    <p:with-param name="word-attr" select="$word-attr"/>
    <p:with-param name="word-attr-val" select="$word-attr-val"/>
    <p:with-param name="output-ns" select="$output-ns"/>
    <p:input port="stylesheet">
      <p:document href="create-valid-breaks.xsl"/>
    </p:input>
  </p:xslt>

  <!-- split the content around the skippable elements -->
  <p:choose name="split">
    <p:when test="$split-skippable = 'true'">
      <p:output port="result"/>
      <p:xslt>
	<p:input port="source">
	  <p:pipe port="result" step="create-valid"/>
	  <p:pipe port="secondary" step="create-valid"/> <!-- sentence ids -->
	</p:input>
	<p:with-param name="can-contain-subsentences" select="$can-contain-subsentences"/>
	<p:with-param name="output-ns" select="$output-ns"/>
	<p:with-param name="skippable-tags" select="$skippable-tags"/>
	<p:with-param name="output-subsentence-tag" select="$output-subsentence-tag"/>
	<p:input port="stylesheet">
	  <p:document href="split-around-skippable.xsl"/>
	</p:input>
      </p:xslt>
      <cx:message message="content split around the skippable elements"/>
    </p:when>
    <p:otherwise>
      <p:output port="result"/>
      <p:identity/>
    </p:otherwise>
  </p:choose>

</p:declare-step>
