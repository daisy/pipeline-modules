<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-create" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">

  <p:output port="result"/>
  <p:option name="base" required="false"/>
  <p:identity>
    <p:input port="source">
      <p:inline exclude-inline-prefixes="px">
        <d:fileset/>
      </p:inline>
    </p:input>
  </p:identity>
  <p:choose>
    <p:when test="p:value-available('base')">
      <p:add-attribute attribute-name="xml:base" match="/d:fileset">
        <p:with-option name="attribute-value" select="$base"/>
      </p:add-attribute>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
</p:declare-step>
