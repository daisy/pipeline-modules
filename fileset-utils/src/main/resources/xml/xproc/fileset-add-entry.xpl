<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-add-entry" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="cx px">

  <p:input port="source"/>
  <p:output port="result"/>

  <p:option name="href" required="true"/>
  <p:option name="media-type" select="''"/>
  <p:option name="first" select="'false'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

<!--TODO awkward, add the entry with XProc, then perform URI cleanup-->
  <p:xslt name="href-uri">
    <p:with-param name="uri" select="$href"/>
    <p:with-param name="base" select="base-uri(/*)"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
          version="2.0" exclude-result-prefixes="#all">
          <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
          <xsl:param name="uri" required="yes"/>
          <xsl:param name="base" required="yes"/>
          <xsl:template match="/*">
            <d:file>
              <xsl:attribute name="href" select="pf:relativize-uri($uri,$base)"/>
            </d:file>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  <p:sink/>

  <p:group>
    <p:variable name="href-uri-ified" select="/*/@href">
      <p:pipe port="result" step="href-uri"/>
    </p:variable>

    <p:identity>
      <p:input port="source">
        <p:pipe port="source" step="main"/>
      </p:input>
    </p:identity>

    <p:choose name="check-base">
      <!--TODO replace by uri-utils 'is-relative' function-->
      <p:when test="not(/*/@xml:base) and not(matches($href-uri-ified,'^[^/]+:'))">
        <cx:message message="Adding a relative resource to a file set with no base URI"/>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>

    <p:group name="new-entry">
      <p:output port="result"/>
      <!--Create the new d:file entry-->
      <p:add-attribute match="/*" attribute-name="media-type">
        <p:input port="source">
          <p:inline>
            <d:file/>
          </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="$media-type"/>
      </p:add-attribute>
      <p:add-attribute match="/*" attribute-name="href">
        <p:with-option name="attribute-value" select="$href-uri-ified"/>
      </p:add-attribute>
      <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="base-uri(/*)">
          <p:pipe port="source" step="main"/>
        </p:with-option>
      </p:add-attribute>
      <p:delete match="@xml:base"/>
      <!--Clean-up the media-type-->
      <p:delete match="@media-type[not(normalize-space())]"/>
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

  </p:group>

</p:declare-step>
