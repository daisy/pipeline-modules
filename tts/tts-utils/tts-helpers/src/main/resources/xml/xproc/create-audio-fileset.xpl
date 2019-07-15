<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:create-audio-fileset" name="main">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Convert a d:audio-clips document to a d:fileset listing (copies of) the audio files.</p>
  </p:documentation>

  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The d:audio-clips document</p>
    </p:documentation>
  </p:input>
  <p:output port="fileset.out" sequence="false" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The d:fileset document</p>
      <p>All audio files referenced from the audio clips are copied to the directory specified with
      the "output-dir" option.</p>
    </p:documentation>
    <p:pipe port="result" step="fileset.result"/>
  </p:output>
  <p:output port="result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Modified version of the input if the "anti-conflict-prefix" option is provided.</p>
    </p:documentation>
    <p:pipe port="result" step="new-audio-map"/>
  </p:output>
  <p:output port="original-files">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The original audio files</p>
      <p>Pass this fileset to px:rm-audio-files later on to delete them.</p>
    </p:documentation>
    <p:pipe port="result" step="audio-files"/>
  </p:output>

  <p:option name="output-dir" required="true"/>
  <p:option name="anti-conflict-prefix" required="false" select="''"/>

  <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
  
  <p:declare-step type="pxi:list-audio-files">
    <p:input port="source">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Audio clips</p>
      </p:documentation>
    </p:input>
    <p:output port="result">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>List of distinct audio files as a d:fileset</p>
      </p:documentation>
    </p:output>
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="list-audio-files.xsl"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>
  </p:declare-step>

  <!-- Iterate over the sound clips of the audio-map. -->
  <pxi:list-audio-files name="audio-files"/>
  <p:for-each name="for-each-audio">
    <p:iteration-source select="//d:file"/>
    <p:variable name="former-href" select="/*/@href">
      <p:pipe port="current" step="for-each-audio"/>
    </p:variable>
    <p:variable name="new-href" select="concat($output-dir, $anti-conflict-prefix, tokenize($former-href, '[\\/]+')[last()])"/>
    <px:fileset-create/>
    <!-- TODO: deal with other format than audio/mpeg -->
    <px:fileset-add-entry first="true" media-type="audio/mpeg">
      <p:with-option name="href" select="$new-href" />
      <p:with-option name="original-href" select="$former-href" />
    </px:fileset-add-entry>
  </p:for-each>
  <px:fileset-join name="fileset.result"/>

  <p:string-replace match="@src" name="new-audio-map">
    <p:input port="source">
      <p:pipe port="source" step="main"/>
    </p:input>
    <p:with-option name="replace"
                   select="concat('replace(., ''/([^/]+)$'', ''/', $anti-conflict-prefix, '$1'')')"/>
  </p:string-replace>

</p:declare-step>
