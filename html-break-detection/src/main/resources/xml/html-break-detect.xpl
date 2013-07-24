<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		type="px:html-break-detect" exclude-inline-prefixes="#all" version="1.0">

  <p:import href="http://www.daisy.org/pipeline/modules/break-detection/break-and-reshape.xpl" />
  
  <p:documentation>Break an input XHTML document into words and sentences by inserting word and sentence elements.</p:documentation>

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>
  
  <px:break-and-reshape>
    <p:with-option name="inline-tags" select="'span,i,b,a,br,del,font,ruby,s,small,strike,strong,sup,u,q,address,abbr,em,style'"/>
    <p:with-option name="space-tags" select="'span,br,ruby,s,address,abbr,style'"/>
    <p:with-option name="output-ns" select="'http://www.w3.org/1999/xhtml'"/>
    <p:with-option name="output-word-tag" select="'span'"/>
    <p:with-option name="word-attr" select="'role'"/>
    <p:with-option name="word-attr-val" select="'word'"/>
    <p:with-option name="output-sentence-tag" select="'span'"/>
    <p:with-option name="sentence-attr" select="'role'"/>
    <p:with-option name="sentence-attr-val" select="'sentence'"/>
  </px:break-and-reshape>

</p:declare-step>
