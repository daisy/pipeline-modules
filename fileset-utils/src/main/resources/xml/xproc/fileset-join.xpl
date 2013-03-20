<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-join" name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all">

  <p:input port="source" sequence="true"/>
  <p:output port="result" primary="true">
    <p:pipe port="result" step="result"/>
  </p:output>

  <p:documentation>Canonicalize all URIs</p:documentation>
  <p:for-each>
    <p:xslt>
      <p:with-param name="base" select="/*/@xml:base">
        <p:pipe port="result" step="first-base"/>
      </p:with-param>
      <p:input port="stylesheet">
        <p:document href="fileset-join.canonicalize.xsl"/>
      </p:input>
    </p:xslt>
    <p:delete match="d:file[@d:base-added]/@xml:base"/>
    <p:delete match="*/@d:base-added"/>
  </p:for-each>

  <p:documentation>Join the filesets</p:documentation>
  <p:wrap-sequence wrapper="d:fileset"/>
  <p:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="fileset-join.xsl"/>
    </p:input>
  </p:xslt>
  <p:unwrap match="/d:fileset/d:fileset"/>
  <p:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="fileset-join.merge-duplicates.xsl"/>
    </p:input>
  </p:xslt>
  <p:identity name="result"/>

  <p:for-each>
    <p:iteration-source>
      <p:pipe port="source" step="main"/>
    </p:iteration-source>
    <p:delete match="/*/*"/>
  </p:for-each>
  <p:wrap-sequence wrapper="c:result"/>
  <p:add-attribute match="/*" attribute-name="xml:base">
    <p:with-option name="attribute-value" select="(/*/d:fileset/@xml:base)[1]"/>
  </p:add-attribute>
  <p:identity name="first-base"/>
  <p:sink/>

</p:declare-step>
