<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">
  
  <p:output port="result"/>
  <p:option name="base"/>
  <p:add-attribute attribute-name="xml:base" match="/d:fileset">
    <p:input port="source">
      <p:inline exclude-inline-prefixes="px">
        <d:fileset/>
      </p:inline>
    </p:input>
    <p:with-option name="attribute-value" select="$base"/>
  </p:add-attribute>
</p:declare-step>
