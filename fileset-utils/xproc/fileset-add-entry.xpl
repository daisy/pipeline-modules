<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-add-entry" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
  exclude-inline-prefixes="px">

  <p:input port="source"/>
  <p:output port="result"/>

  <p:option name="href" required="true"/>
  <p:option name="media-type"/>
  <p:option name="first" select="'false'"/>

  <!-- Create a new d:entry element -->
  <p:group name="fileset-add-entry.create-entry">
    <p:output port="result"/>
    <p:add-attribute match="/d:file" attribute-name="href">
      <p:input port="source">
        <p:inline>
          <d:file/>
        </p:inline>
      </p:input>
      <p:with-option name="attribute-value" select="$href"/>
    </p:add-attribute>
    <p:choose>
      <p:when test="p:value-available('media-type')">
        <p:add-attribute match="/d:file" attribute-name="media-type">
          <p:with-option name="attribute-value" select="$media-type"/>
        </p:add-attribute>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>
  </p:group>
  <!-- Add the d:entry to the source d:fileset -->
  <p:insert match="/*">
    <p:input port="source">
      <p:pipe port="source" step="fileset-add-entry"/>
    </p:input>
    <p:input port="insertion">
      <p:pipe port="result" step="fileset-add-entry.create-entry"/>
    </p:input>
    <p:with-option name="position" select="if ($first='true') then 'first-child' else 'last-child'"
    />
  </p:insert>
  <!-- Add xml:base on all d:entry and on the d:fileset -->
  <p:label-elements match="d:file[not(@xml:base)]" attribute="xml:base" label="base-uri(..)"/>
  <p:add-xml-base/>
</p:declare-step>
