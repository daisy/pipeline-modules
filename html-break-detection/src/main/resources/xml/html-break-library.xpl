<?xml version="1.0" encoding="UTF-8"?>
<p:library version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml">

  <p:declare-step type="px:html-break-detect">

    <p:import href="http://www.daisy.org/pipeline/modules/break-detection/break-and-reshape.xpl" />

    <p:documentation>Break an input XHTML document into words and sentences by inserting word and sentence elements.</p:documentation>

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:output port="sentence-ids">
      <p:pipe port="sentence-ids" step="generic"/>
    </p:output>

    <px:break-and-reshape name="generic">
      <p:with-option name="inline-tags" select="'span,i,b,a,br,del,font,ruby,s,small,strike,strong,sup,u,q,address,abbr,em,style'"/>
      <p:with-option name="ensure-word-before" select="'span,br,ruby,s,address,abbr,style'"/>
      <p:with-option name="ensure-word-after" select="'span,br,ruby,s,address,abbr,style'"/>
      <p:with-option name="can-contain-sentences" select="'span,p,div'"/>
      <p:with-option name="can-contain-subsentences" select="'span,p,div'"/>
      <p:with-option name="output-ns" select="'http://www.w3.org/1999/xhtml'"/>
      <p:with-option name="output-word-tag" select="'span'"/>
      <p:with-option name="word-attr" select="'role'"/>
      <p:with-option name="word-attr-val" select="'word'"/>
      <p:with-option name="output-sentence-tag" select="'span'"/>
    </px:break-and-reshape>

  </p:declare-step>

  <p:declare-step type="px:html-unwrap-words">

    <p:documentation>Remove the word markups from the input document.</p:documentation>

    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:unwrap match="xhtml:span[@role='word']" />
  </p:declare-step>

</p:library>
