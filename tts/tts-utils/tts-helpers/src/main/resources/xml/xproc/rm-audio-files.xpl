<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                type="px:rm-audio-files">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Delete audio files.</p>
  </p:documentation>

  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>A d:fileset document that was returned by px:create-audio-fileset which lists the original
      files of which copies were made.</p>
    </p:documentation>
  </p:input>

  <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
    <p:documentation>
      px:delete
    </p:documentation>
  </p:import>

  <p:for-each>
    <p:iteration-source select="//d:file[@temp-audio-file]"/>
    <px:delete>
      <p:with-option name="href" select="/*/@href"/>
    </px:delete>
  </p:for-each>

</p:declare-step>
