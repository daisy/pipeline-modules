<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:z="http://www.daisy.org/ns/z3998/authoring/"
		type="px:zedai-break-detect" exclude-inline-prefixes="#all" version="1.0">

  <p:import href="http://www.daisy.org/pipeline/modules/break-detection/break-and-reshape.xpl" />
  
  <p:documentation>Break an input zedai document into words and sentences by inserting word and sentence elements.</p:documentation>

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>
  
  <px:break-and-reshape>
    <p:with-option name="inline-tags" select="'emph,span,ref,char,term,sub,ref,sup,pagebreak,name'"/>
    <p:with-option name="space-tags" select="'span'"/>
    <p:with-option name="output-ns" select="'http://www.daisy.org/ns/z3998/authoring'"/>
    <p:with-option name="output-word-tag" select="'w'"/>
    <p:with-option name="output-sentence-tag" select="'s'"/>
  </px:break-and-reshape>

</p:declare-step>
