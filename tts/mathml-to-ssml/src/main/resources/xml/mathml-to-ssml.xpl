<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:mathml-to-ssml" version="1.0" name="main"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		exclude-inline-prefixes="#all">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Transform MathML to SSML.</p>
  </p:documentation>

  <p:input port="source" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>A sequence of MathML documents.</p>
    </p:documentation>
  </p:input>
  <p:output port="result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>A SSML document containing the transformed MathML.</p>
    </p:documentation>
  </p:output>

  <!-- Convert Content into Presentation MathML if any -->
  <!-- TODO: improve Content MathML detection -->
  <p:for-each>
    <p:choose>
      <p:when test="empty(//m:apply|//m:set|//m:list|//m:matrix|//m:vector)">
  	<p:identity/>
      </p:when>
      <p:otherwise>
      	<p:xslt>
      	  <p:input port="stylesheet">
      	    <p:document href="content-to-pres/mathmlc2p.xsl"/>
      	  </p:input>
      	  <p:input port="parameters">
      	    <p:empty/>
      	  </p:input>
      	</p:xslt>
      </p:otherwise>
    </p:choose>
  </p:for-each>
  <p:wrap-sequence wrapper="m:wrapper"/>

  <!-- Main conversion (Presentation Mathml to SSML) -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="pres-to-ssml/pres-mathml-to-ssml.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
