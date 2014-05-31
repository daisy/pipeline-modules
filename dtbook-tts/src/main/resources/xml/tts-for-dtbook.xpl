<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="main" type="px:tts-for-dtbook"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		exclude-inline-prefixes="#all">

  <p:input port="content.in" primary="true" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>List of DTBook documents.</p>
    </p:documentation>
  </p:input>

  <p:input port="fileset.in">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
       <p>Input fileset including DTBook documents, lexicons and CSS stylesheets.</p>
    </p:documentation>
  </p:input>

  <p:output port="audio-map">
    <p:pipe port="audio-map" step="synthesize"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
       <p>List of audio clips (see pipeline-mod-tts documentation).</p>
    </p:documentation>
  </p:output>

  <p:output port="content.out" primary="true" sequence="true">
    <p:pipe port="result" step="lexing"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
       <p>Copy of the DTBook documents enriched with ids, words and sentences.</p>
    </p:documentation>
  </p:output>

  <p:output port="sentence-ids" sequence="true">
    <p:pipe port="sentence-ids" step="lexing"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Every document of this port is a list of nodes whose id
      attribute refers to elements of the 'content.out'
      documents. Grammatically speaking, the referred elements are
      sentences even if the underlying XML elements are not meant to
      be so. Documents are listed in the same order as in
      'content.out'.</p>
    </p:documentation>
  </p:output>

  <p:option name="audio" required="false" px:type="boolean" select="'true'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Enable Text-To-Speech</h2>
      <p px:role="desc">Whether to use a speech synthesizer to produce audio files.</p>
    </p:documentation>
  </p:option>

  <p:option name="aural-css" required="false" px:type="anyURI" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Aural CSS sheet</h2>
      <p px:role="desc">Path of an additional Aural CSS stylesheet for the Text-To-Speech.</p>
    </p:documentation>
  </p:option>

  <p:option name="ssml-of-lexicons-uris" required="false" px:type="anyURI" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2 px:role="name">Lexicons SSML pointers</h2>
      <p px:role="desc">URI of an SSML file which contains a list of
      lexicon elements with their URI. The lexicons will be provided
      to the Text-To-Speech processors.</p>
    </p:documentation>
  </p:option>

  <p:import href="http://www.daisy.org/pipeline/modules/ssml-to-audio/ssml-to-audio.xpl" />
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-to-ssml/dtbook-to-ssml.xpl" />
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-break-detection/library.xpl"/>

  <!-- Find the sentences and the words, even if the Text-To-Speech is off. -->
  <p:for-each name="lexing">
    <p:iteration-source>
      <!-- For now, the for-each is actually not needed since there is
           only one DTBook. -->
      <p:pipe port="content.in" step="main"/>
    </p:iteration-source>
    <p:output port="result">
      <p:pipe port="result" step="break"/>
    </p:output>
    <p:output port="sentence-ids">
      <p:pipe port="sentence-ids" step="break"/>
    </p:output>
    <px:dtbook-break-detect name="break"/>
  </p:for-each>

  <p:choose name="synthesize">
    <p:when test="$audio = 'false'">
      <p:output port="audio-map"/>
      <p:identity>
	<p:input port="source">
	  <p:inline>
	    <d:audio-clips/>
	  </p:inline>
	</p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:output port="audio-map">
	<p:pipe port="result" step="to-audio"/>
      </p:output>
      <p:for-each name="for-each.content">
	<p:iteration-source>
	  <p:pipe port="result" step="lexing"/>
	</p:iteration-source>
	<p:output port="ssml.out" primary="true" sequence="true">
	  <p:pipe port="result" step="ssml-gen"/>
	</p:output>
	<p:split-sequence name="sentences">
	  <p:input port="source">
	    <p:pipe port="sentence-ids" step="lexing"/>
	  </p:input>
	  <p:with-option name="test" select="concat('position()=', p:iteration-position())"/>
	</p:split-sequence>
	<px:dtbook-to-ssml name="ssml-gen">
	  <p:input port="content.in">
	    <p:pipe port="current" step="for-each.content"/>
	  </p:input>
	  <p:input port="sentence-ids">
	    <p:pipe port="matched" step="sentences"/>
	  </p:input>
	  <p:input port="fileset.in">
	    <p:pipe port="fileset.in" step="main"/>
	  </p:input>
	  <p:with-option name="css-sheet-uri" select="$aural-css"/>
	  <p:with-option name="ssml-of-lexicons-uris" select="$ssml-of-lexicons-uris"/>
	</px:dtbook-to-ssml>
      </p:for-each>
      <px:ssml-to-audio name="to-audio"/>
    </p:otherwise>
  </p:choose>

</p:declare-step>
