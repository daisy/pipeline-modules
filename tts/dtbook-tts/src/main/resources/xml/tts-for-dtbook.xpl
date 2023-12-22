<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                type="px:tts-for-dtbook" name="main"
                exclude-inline-prefixes="#all">

  <p:input port="source.fileset" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The source fileset with Dtbook documents, lexicons and CSS stylesheets.</p>
    </p:documentation>
  </p:input>
  <p:input port="source.in-memory" sequence="true"/>

  <p:input port="config">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
       <p>Configuration file with lexicons, voices declaration and various properties.</p>
    </p:documentation>
  </p:input>

  <p:output port="audio-map">
    <p:pipe port="audio-map" step="synthesize"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
       <p>List of audio clips mapped to unique IDs in the DTBook document set.</p>
    </p:documentation>
  </p:output>

  <p:output port="result.fileset" primary="true"/>
  <p:output port="result.in-memory" sequence="true">
    <p:pipe step="update-fileset" port="result.in-memory"/>
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The result fileset.</p>
      <p>DTBook documents are enriched with IDs, words and sentences. Inlined aural CSS is
      removed.</p>
    </p:documentation>
  </p:output>

  <p:output port="status">
    <p:pipe step="synthesize" port="status"/>
  </p:output>

  <p:option name="include-log" select="'false'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Whether or not to make the TTS log available on the "log" port.</p>
    </p:documentation>
  </p:option>
  <p:output port="log" sequence="true">
    <p:pipe step="synthesize" port="log"/>
  </p:output>

  <p:option name="audio" required="false" cx:type="xs:boolean" select="'true'" cx:as="xs:string">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <h2>Enable Text-To-Speech</h2>
      <p>Whether to use a speech synthesizer to produce audio files.</p>
    </p:documentation>
  </p:option>

  <p:option name="audio-file-type" select="'audio/mpeg'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The desired file type of the generated audio files, specified as a MIME type.</p>
      <p>Examples:</p>
      <ul>
        <li>"audio/mpeg"</li>
        <li>"audio/x-wav"</li>
      </ul>
    </p:documentation>
  </p:option>

  <p:option name="process-css" required="false" select="'true'" cx:as="xs:string">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Set to false to bypass aural CSS processing.</p>
    </p:documentation>
  </p:option>

  <p:option name="word-detection" required="false" select="'true'" cx:as="xs:string">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Whether to detect and mark up words with <code>&lt;w&gt;</code> tags.</p>
    </p:documentation>
  </p:option>

  <p:option name="temp-dir" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Empty directory dedicated to this conversion. May be left empty in which case a temporary
      directory will be automatically created.</p>
    </p:documentation>
  </p:option>

  <p:import href="dtbook-to-ssml.xpl">
    <p:documentation>
      px:dtbook-to-ssml
    </p:documentation>
  </p:import>
  <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
    <p:documentation>
      px:add-ids
    </p:documentation>
  </p:import>
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-break-detection/library.xpl">
    <p:documentation>
      px:dtbook-break-detect
      px:dtbook-unwrap-words
    </p:documentation>
  </p:import>
  <p:import href="http://www.daisy.org/pipeline/modules/tts-common/library.xpl">
    <p:documentation>
      px:ssml-to-audio
      px:isolate-skippable
    </p:documentation>
  </p:import>
  <p:import href="http://www.daisy.org/pipeline/modules/css-speech/library.xpl">
    <p:documentation>
      px:css-speech-cascade
      px:css-speech-clean
    </p:documentation>
  </p:import>
  <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
    <p:documentation>
      px:fileset-load
      px:fileset-update
      px:fileset-compose
    </p:documentation>
  </p:import>
  <p:import href="http://www.daisy.org/pipeline/modules/dtbook-utils/library.xpl">
    <p:documentation>
      px:dtbook-update-links
    </p:documentation>
  </p:import>

  <p:choose name="process-css">
    <p:when test="$audio='true' and $process-css='true'">
      <p:output port="fileset" primary="true"/>
      <p:output port="in-memory" sequence="true">
        <p:pipe step="cascade" port="result.in-memory"/>
      </p:output>
      <px:css-speech-cascade content-type="application/x-dtbook+xml" name="cascade">
        <p:input port="source.in-memory">
          <p:pipe step="main" port="source.in-memory"/>
        </p:input>
        <p:input port="config">
          <p:pipe step="main" port="config"/>
        </p:input>
      </px:css-speech-cascade>
    </p:when>
    <p:otherwise>
      <p:output port="fileset" primary="true"/>
      <p:output port="in-memory" sequence="true">
        <p:pipe step="main" port="source.in-memory"/>
      </p:output>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <px:fileset-load media-types="application/x-dtbook+xml" name="dtbook">
    <p:input port="in-memory">
      <p:pipe step="process-css" port="in-memory"/>
    </p:input>
  </px:fileset-load>

  <!-- Find the sentences and the words, even if the Text-To-Speech is off. -->
  <!-- It is necessary to apply px:dtbook-break-detect and px:isolate-skippable to
       split the content around the skippable elements (pagenums and noterefs) so
       they can be attached to a smilref attribute that won't be the descendant of
       any audio clip. Otherwise we risk having pagenums without @smilref, which
       is not allowed by the specs. -->
  <p:group name="lexing">
    <p:output port="result" sequence="true" primary="true"/>
    <p:output port="sentence-ids">
      <p:pipe step="sentence-ids" port="result"/>
    </p:output>
    <p:output port="skippable-ids">
      <p:pipe step="skippable-ids" port="result"/>
    </p:output>
    <p:for-each name="for-each">
      <p:output port="result" primary="true"/>
      <p:output port="sentence-ids">
	<p:pipe step="break" port="sentence-ids"/>
      </p:output>
      <p:output port="skippable-ids">
	<p:pipe step="isolate-skippable" port="skippable-ids"/>
      </p:output>
      <px:dtbook-break-detect name="break"/>
      <px:isolate-skippable name="isolate-skippable"
			    match="dtb:pagenum|dtb:noteref|dtb:annoref|dtb:linenum|math:math">
	<p:input port="sentence-ids">
	  <p:pipe step="break" port="sentence-ids"/>
	</p:input>
      </px:isolate-skippable>
    </p:for-each>
    <px:add-ids name="fix-duplicate-ids">
      <p:documentation>Fix duplicate IDs.</p:documentation>
    </px:add-ids>
    <p:sink/>
    <p:group name="sentence-ids">
      <p:documentation>Apply ID mapping to sentence IDs</p:documentation>
      <p:output port="result"/>
      <p:for-each>
	<p:iteration-source>
	  <p:pipe step="for-each" port="sentence-ids"/>
	</p:iteration-source>
	<p:rename match="d:sentences" new-name="d:file"/>
	<p:rename match="d:sentence" new-name="d:anchor"/>
	<p:label-elements match="/*" attribute="href" label="base-uri(.)"/>
      </p:for-each>
      <p:wrap-sequence wrapper="d:fileset" name="sentence-fileset"/>
      <p:sink/>
      <px:fileset-compose limit-scope="true">
	<p:input port="source">
	  <p:pipe step="sentence-fileset" port="result"/>
	  <p:pipe step="fix-duplicate-ids" port="mapping"/>
	</p:input>
      </px:fileset-compose>
    </p:group>
    <p:sink/>
    <p:group name="skippable-ids">
      <p:documentation>Apply ID mapping to skippable IDs</p:documentation>
      <p:output port="result"/>
      <p:for-each>
	<p:iteration-source>
	  <p:pipe step="for-each" port="skippable-ids"/>
	</p:iteration-source>
	<p:rename match="d:skippables" new-name="d:file"/>
	<p:rename match="d:skippable" new-name="d:anchor"/>
	<p:label-elements match="/*" attribute="href" label="base-uri(.)"/>
      </p:for-each>
      <p:wrap-sequence wrapper="d:fileset" name="skippable-fileset"/>
      <p:sink/>
      <px:fileset-compose limit-scope="true">
	<p:input port="source">
	  <p:pipe step="skippable-fileset" port="result"/>
	  <p:pipe step="fix-duplicate-ids" port="mapping"/>
	</p:input>
      </px:fileset-compose>
    </p:group>
    <p:sink/>
    <p:for-each>
      <p:documentation>Apply ID mapping to enriched DTBooks</p:documentation>
      <p:iteration-source>
	<p:pipe step="fix-duplicate-ids" port="result"/>
      </p:iteration-source>
      <px:dtbook-update-links>
	<p:input port="mapping">
	  <p:pipe step="fix-duplicate-ids" port="mapping"/>
	</p:input>
      </px:dtbook-update-links>
    </p:for-each>
  </p:group>

  <p:choose name="synthesize" px:progress="1">
    <p:when test="$audio = 'false'">
      <p:output port="audio-map">
	<p:inline>
	  <d:audio-clips/>
	</p:inline>
      </p:output>
      <p:output port="status">
	<p:inline>
	  <d:status result="ok"/>
	</p:inline>
      </p:output>
      <p:output port="log" sequence="true">
        <p:empty/>
      </p:output>
      <p:sink/>
    </p:when>
    <p:otherwise>
      <p:output port="audio-map">
	<p:pipe step="to-audio" port="result"/>
      </p:output>
      <p:output port="status">
	<p:pipe step="to-audio" port="status"/>
      </p:output>
      <p:output port="log" sequence="true">
        <p:pipe step="to-audio" port="log"/>
      </p:output>
      <p:for-each>
	<p:output port="ssml" primary="true" sequence="true">
	  <p:pipe port="result" step="ssml-gen"/>
	</p:output>
	<px:dtbook-to-ssml name="ssml-gen" px:message="SSML generation for DTBook">
	  <p:input port="sentence-ids">
	    <p:pipe step="lexing" port="sentence-ids"/>
	  </p:input>
	  <p:input port="skippable-ids">
	    <p:pipe step="lexing" port="skippable-ids"/>
	  </p:input>
	  <p:input port="fileset.in">
	    <p:pipe step="process-css" port="fileset"/>
	  </p:input>
	  <p:input port="config">
	    <p:pipe port="config" step="main"/>
	  </p:input>
	</px:dtbook-to-ssml>
      </p:for-each>
      <px:ssml-to-audio name="to-audio" px:progress="1">
	<p:with-option name="audio-file-type" select="$audio-file-type">
	  <p:empty/>
	</p:with-option>
	<p:with-option name="include-log" select="$include-log">
	  <p:empty/>
	</p:with-option>
	<p:input port="config">
	  <p:pipe port="config" step="main"/>
	</p:input>
	<p:with-option name="temp-dir" select="if ($temp-dir!='') then concat($temp-dir,'audio/') else ''">
	  <p:empty/>
	</p:with-option>
      </px:ssml-to-audio>
    </p:otherwise>
  </p:choose>

  <p:for-each>
    <p:iteration-source>
      <p:pipe port="result" step="lexing"/>
    </p:iteration-source>
    <px:css-speech-clean/>
  </p:for-each>
  <p:choose>
    <p:when test="$word-detection='false'">
      <px:dtbook-unwrap-words/>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  <p:identity name="clean-dtbook"/>
  <p:sink/>

  <px:fileset-update name="update-fileset">
    <p:input port="source.fileset">
      <p:pipe step="process-css" port="fileset"/>
    </p:input>
    <p:input port="source.in-memory">
      <p:pipe step="process-css" port="in-memory"/>
    </p:input>
    <p:input port="update.fileset">
      <p:pipe step="dtbook" port="result.fileset"/>
    </p:input>
    <p:input port="update.in-memory">
      <p:pipe step="clean-dtbook" port="result"/>
    </p:input>
  </px:fileset-update>

</p:declare-step>
