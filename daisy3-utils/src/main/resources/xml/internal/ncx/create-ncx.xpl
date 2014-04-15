<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="px:create-ncx" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    version="1.0">

    <p:input port="content" primary="true"/> <!-- with the smilref -->
    <p:input port="audio-map"/>

    <p:option name="audio-dir"/>
    <p:option name="mo-dir"/>
    <p:option name="ncx-dir"/>
    <p:option name="uid"/>

    <p:output port="result" primary="true">
      <p:pipe port="result" step="create-ncx"/>
    </p:output>

    <p:xslt>
      <p:input port="source">
	<p:pipe port="content" step="main"/>
	<p:pipe port="audio-map" step="main"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="create-ncx.xsl"/>
      </p:input>
      <p:with-param name="mo-dir" select="$mo-dir"/>
      <p:with-param name="audio-dir" select="$audio-dir"/>
      <p:with-param name="ncx-dir" select="$ncx-dir"/>
      <p:with-param name="uid" select="$uid"/>
    </p:xslt>

    <p:add-attribute name="create-ncx" match="/*" attribute-name="xml:base">
      <p:with-option name="attribute-value" select="concat($ncx-dir, 'navigation.ncx')"/>
    </p:add-attribute>

</p:declare-step>
