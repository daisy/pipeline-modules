<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                type="px:daisy3-prepare-dtbook">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Add missing elements to a DTBook so as to make the NCX/OPF/SMIL generation easier.</p>
    </p:documentation>

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="mathml-formulae-img" select="''"/>

    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="fix-dtbook-structure.xsl"/>
      </p:input>
      <p:with-param name="mathml-formulae-img" select="$mathml-formulae-img"/>
    </p:xslt>

</p:declare-step>
