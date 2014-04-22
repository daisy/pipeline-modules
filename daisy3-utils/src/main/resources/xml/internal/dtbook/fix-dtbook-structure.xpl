<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="px:fix-dtbook-structure" version="1.0"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc">

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>

    <p:xslt>
      <p:input port="stylesheet">
	<p:document href="fix-dtbook-structure.xsl"/>
      </p:input>
      <p:input port="parameters">
	<p:empty/>
      </p:input>
    </p:xslt>

</p:declare-step>
