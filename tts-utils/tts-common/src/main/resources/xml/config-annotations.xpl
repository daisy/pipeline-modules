<p:declare-step type="px:annotate" version="1.0" name="main"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:xml="http://www.w3.org/XML/1998/namespace"
		exclude-inline-prefixes="#all">

  <p:input port="config" primary="true"/>
  <p:output port="result" primary="true"/>
  <p:option name="content-type"/>

  <p:variable name="href" select="//*[local-name()='annotations' and @href and @type=$content-type]/@href"/>

  <p:choose>
    <p:when test="$href">
      <p:output port="result" primary="true"/>
      <p:load>
	<p:with-option name="href" select="resolve-uri($href, base-uri(/*))"/>
      </p:load>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <p:identity>
	<p:input port="source">
	  <p:inline>
	    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"/>
	  </p:inline>
	</p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

</p:declare-step>
