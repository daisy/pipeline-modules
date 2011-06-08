<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-add-entry" name="main"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="cx px">

  <p:input port="source"/>
  <p:output port="result"/>

  <p:option name="href" required="true"/>
  <p:option name="media-type"/>
  <p:option name="first" select="'false'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:in-scope-names name="vars"/>
  
  <p:identity>
    <p:input port="source">
      <p:pipe port="source" step="main"/>
    </p:input>
  </p:identity>
  
  <p:choose name="check-base">
    <!--TODO replace by uri-utils 'is-relative' function-->
    <p:when test="not(/*/@xml:base) and not(matches($href,'^[^/]+:'))">
      <cx:message message="Adding a relative resource to a file set with no base URI"/>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
  <p:group name="new-entry">
    <p:output port="result"/>
    <!--Create the new d:file entry-->
    <p:template>
      <p:input port="template">
        <p:inline>
          <d:file
            href="{if (starts-with($href,replace(base-uri(/*),'/+','/'))) 
            then substring-after($href,base-uri(/*)) 
            else $href}"
            media-type="{$media-type}"
          />
        </p:inline>
      </p:input>
      <p:input port="parameters">
        <p:pipe step="vars" port="result"/>
      </p:input>
    </p:template>
    <!--Clean-up the media-type-->
    <p:delete match="@media-type[not(normalize-space())]"/>
    <!--Fix-up the xml:base to the file set's base-->
    <p:label-elements attribute="xml:base">
      <p:with-option name="label" select="concat('&quot;',base-uri(/*),'&quot;')">
        <p:pipe port="source" step="main"/>
      </p:with-option>
    </p:label-elements>
  </p:group>
  
  <!--Insert the entry as the last or first child of the file set-->
  <p:insert match="/*">
    <p:input port="source">
      <p:pipe port="source" step="main"/>
    </p:input>
    <p:input port="insertion">
      <p:pipe port="result" step="new-entry"/>
    </p:input>
    <p:with-option name="position" select="if ($first='true') then 'first-child' else 'last-child'"/>
  </p:insert>
  
  <p:add-xml-base/>
</p:declare-step>
