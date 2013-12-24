<p:declare-step type="px:break-and-reshape"
		version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
		exclude-inline-prefixes="#all">

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="break-detect.xpl"/>

  <p:option name="can-contain-sentences" required="true">
    <p:documentation>
      Comma-separated list of elements that can be direct parent of
      sentences, words and sub-sentences.
    </p:documentation>
  </p:option>

  <p:option name="special-sentences" required="false" select="''">
    <p:documentation>
      Comma-separated list of elements that cannot contain sentence
      elements but must be considered as sentences (such as DTBook
      pagenums). They must be able to hold an ID attribute.
    </p:documentation>
  </p:option>

  <p:option name="inline-tags" required="true">
    <p:documentation>
      Comma-separated list of elements that do not necessary separate
      sentences.
    </p:documentation>
  </p:option>

  <p:option name="output-word-tag" required="true">
    <p:documentation>
      Name of the element used for representing a word.
    </p:documentation>
  </p:option>

  <p:option name="output-sentence-tag" required="true">
    <p:documentation>
      Name of the element used for representing a sentence.
    </p:documentation>
  </p:option>

  <p:option name="word-attr" required="false" select="''">
    <p:documentation>
      Attribute name of the element used for representing a word.
    </p:documentation>
  </p:option>

  <p:option name="word-attr-val" required="false" select="''">
    <p:documentation>
      Corresponding attribute value of the option 'word-attr'.
    </p:documentation>
  </p:option>

  <p:option name="output-ns" required="true">
    <p:documentation>
      Output namespace in which the words and the sentences will be
      created.
    </p:documentation>
  </p:option>

  <p:option name="ensure-word-before" required="false" select="''">
    <p:documentation>
      Comma-separated list of elements. When such elements are
      detected, the Lexer is forced to end the current word.
    </p:documentation>
  </p:option>
  <p:option name="ensure-word-after" required="false" select="''"/>

  <p:option name="ensure-sentence-before" required="false" select="''">
    <p:documentation>
      Comma-separated list of elements. When such elements are
      detected, the Lexer is forced to end the current sentence.
    </p:documentation>
  </p:option>
  <p:option name="ensure-sentence-after" required="false" select="''"/>

  <p:option name="split-skippable" required="false" select="'false'">
    <p:documentation>
      If this option is enable, the script will wrap the nodes around
      the elements of 'skippable-tags' with a node of type given by
      'output-subsentence-tag'. The standard must allow the elements
      of 'output-subsentence-tag' to hold an ID.
    </p:documentation>
  </p:option>
  <p:option name="skippable-tags" required="false" select="''"/>
  <p:option name="output-subsentence-tag" required="true"/>

  <p:input port="source" primary="true">
    <p:documentation>
      Input document (Zedai, DTBook etc.).
    </p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>
      Input document with the words and the sentences.
    </p:documentation>
  </p:output>

  <p:output port="sentence-ids">
    <p:pipe port="secondary" step="create-valid"/>
    <p:documentation>
      List of the sentences' id.
    </p:documentation>
  </p:output>

  <!-- The tags are chosen to not conflict with other elements as the
       namespace may not be used in the XSLT scripts. -->
  <p:variable name="tmp-ns" select="'http://www.daisy.org/ns/pipeline/tmp'"/>
  <p:variable name="tmp-word-tag" select="'ww'"/>
  <p:variable name="tmp-sentence-tag" select="'ss'"/>

  <!-- run the java-based lexing step -->
  <px:break-detect name="break">
    <p:with-option name="inline-tags" select="$inline-tags"/>
    <p:with-option name="output-word-tag" select="$tmp-word-tag"/>
    <p:with-option name="output-sentence-tag" select="$tmp-sentence-tag"/>
    <p:with-option name="tmp-ns" select="$tmp-ns"/>
    <p:with-option name="ensure-word-before" select="$ensure-word-before"/>
    <p:with-option name="ensure-word-after" select="$ensure-word-after"/>
    <p:with-option name="ensure-sentence-before" select="$ensure-sentence-before"/>
    <p:with-option name="ensure-sentence-after" select="$ensure-sentence-after"/>
  </px:break-detect>
  <cx:message message="Java-based break detection done."/>

  <!-- Distribute some sentences to prevent them from having parents
       not compliant with the format. -->
  <p:xslt name="distribute">
    <p:with-param name="can-contain-sentences" select="$can-contain-sentences"/>
    <p:with-param name="tmp-word-tag" select="$tmp-word-tag"/>
    <p:with-param name="tmp-sentence-tag" select="$tmp-sentence-tag"/>
    <p:with-param name="tmp-ns" select="$tmp-ns"/>
    <p:input port="stylesheet">
      <p:document href="distribute-sentences.xsl"/>
    </p:input>
  </p:xslt>
  <cx:message message="Sentences distributed."/>

  <!-- Create the actual sentence/word elements. -->
  <p:xslt name="create-valid">
    <p:with-param name="can-contain-words" select="$can-contain-sentences"/>
    <p:with-param name="special-sentences" select="$special-sentences"/>
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
  <cx:message message="Format-compliant elements inserted."/>

  <!-- split the content around the skippable elements -->
  <p:choose name="split">
    <p:when test="$split-skippable = 'true'">
      <p:output port="result"/>
      <p:xslt>
	<p:input port="source">
	  <p:pipe port="result" step="create-valid"/>
	  <p:pipe port="secondary" step="create-valid"/> <!-- sentence ids -->
	</p:input>
	<p:with-param name="can-contain-subsentences" select="concat($can-contain-sentences, ',', $output-sentence-tag)"/>
	<p:with-param name="output-ns" select="$output-ns"/>
	<p:with-param name="skippable-tags" select="$skippable-tags"/>
	<p:with-param name="output-subsentence-tag" select="$output-subsentence-tag"/>
	<p:input port="stylesheet">
	  <p:document href="split-around-skippable.xsl"/>
	</p:input>
      </p:xslt>
      <cx:message message="Content split around the skippable elements."/>
    </p:when>
    <p:otherwise>
      <p:output port="result"/>
      <p:identity/>
    </p:otherwise>
  </p:choose>

</p:declare-step>
