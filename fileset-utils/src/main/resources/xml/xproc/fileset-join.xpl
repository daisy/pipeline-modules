<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-join" name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:di="http://www.daisy.org/ns/pipeline/data/internal" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" exclude-inline-prefixes="#all">
  
  <p:serialization port="result" undeclare-prefixes="true"/>
  
  <p:input port="source" sequence="true"/>
  <p:output port="result" primary="true">
    <p:pipe port="result" step="result"/>
  </p:output>

  <!-- helper for pxi:xslt -->
  <p:declare-step type="pxi:annotate-base">
    <p:input port="source"/>
    <p:output port="result"/>
    <p:add-attribute match="/*" attribute-name="di:_base">
      <p:with-option name="attribute-value" select="base-uri(/*)"/>
    </p:add-attribute>
    
    <!-- for debugging -->
    <!--<p:add-attribute match="/*" attribute-name="base-history">
      <p:with-option name="attribute-value" select="string-join((/*/@base-history,/*/base-uri(.)),' | ')"/>
    </p:add-attribute>
    <p:add-attribute match="/*" attribute-name="href-history">
      <p:with-option name="attribute-value" select="if (/*[@href]) then string-join((/*/@href-history,/*/@href),' | ') else /*/@href-history"/>
    </p:add-attribute>-->
    
    <p:viewport match="/*/*">
      <pxi:annotate-base/>
    </p:viewport>
  </p:declare-step>

  <!-- helper for pxi:xslt -->
  <p:declare-step type="pxi:reset-base">
    <p:input port="source"/>
    <p:output port="result"/>
    <p:choose>
      <p:when test="/*[@xml:base]">
        <p:identity/>
      </p:when>
      <p:otherwise>
        <p:add-attribute match="/*" attribute-name="xml:base">
          <p:with-option name="attribute-value" select="/*/@di:_base"/>
        </p:add-attribute>
        <p:delete match="/*/@xml:base"/>
      </p:otherwise>
    </p:choose>
    <p:delete match="/*/@di:_base"/>
    <p:viewport match="/*/*">
      <pxi:reset-base/>
    </p:viewport>
  </p:declare-step>

  <!-- wrapper for p:xslt that preserves base uris for all elements -->
  <p:declare-step type="pxi:xslt" name="pxi-xslt">
    <p:input port="source" primary="true"/>
    <p:input port="stylesheet"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result" primary="true"/>
    <pxi:annotate-base/>
    <p:xslt>
      <p:input port="stylesheet">
        <p:pipe port="stylesheet" step="pxi-xslt"/>
      </p:input>
    </p:xslt>
    <pxi:reset-base/>
  </p:declare-step>

  <p:documentation>Canonicalize all URIs</p:documentation>
  <p:for-each>
    <pxi:xslt>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:input port="stylesheet">
        <p:document href="fileset-join.canonicalize.xsl"/>
      </p:input>
    </pxi:xslt>
  </p:for-each>

  <p:documentation>Join the filesets</p:documentation>
  <p:wrap-sequence wrapper="d:fileset"/>
  <pxi:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="fileset-join.xsl"/>
    </p:input>
  </pxi:xslt>
  <p:delete match="/*[@di:_delete-base]/@xml:base | /*[@di:_delete-base]/@di:_delete-base"/>
  <p:unwrap match="/d:fileset/d:fileset"/>
  <pxi:xslt>
    <!-- canonicalize resulting URIs -->
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="fileset-join.canonicalize.xsl"/>
    </p:input>
  </pxi:xslt>
  <pxi:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="fileset-join.merge-duplicates.xsl"/>
    </p:input>
  </pxi:xslt>
  <p:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="fileset-join.normalize-base-uris.xsl"/>
    </p:input>
  </p:xslt>
  <p:identity name="result"/>

</p:declare-step>
