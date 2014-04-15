<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="px:create-daisy3-opf" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    version="1.0">

    <p:input port="source" primary="true">
      <p:documentation>The fileset.</p:documentation>
    </p:input>

    <p:option name="output-dir"/>
    <p:option name="title"/>
    <p:option name="uid"/>
    <p:option name="total-time"/>
    <p:option name="opf-uri"/>
    <p:option name="lang"/>
    <p:option name="publisher"/>

    <p:output port="result" primary="true"/>

    <p:xslt>
      <p:input port="stylesheet">
	<p:document href="create-opf.xsl"/>
      </p:input>
      <p:with-param name="lang" select="$lang"/>
      <p:with-param name="publisher" select="$publisher"/>
      <p:with-param name="output-dir" select="$output-dir"/>
      <p:with-param name="uid" select="$uid"/>
      <p:with-param name="title" select="$title"/>
      <p:with-param name="total-time" select="$total-time"/>
    </p:xslt>

    <p:add-attribute match="/*" attribute-name="xml:base">
      <p:with-option name="attribute-value" select="$opf-uri"/>
    </p:add-attribute>

</p:declare-step>
