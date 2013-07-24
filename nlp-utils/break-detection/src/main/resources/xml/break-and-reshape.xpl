<p:declare-step type="px:break-and-reshape"
		version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp">

  <p:import href="break-detect.xpl"/>
  <p:import href="repeat-merge.xpl"/>

    
  <p:option name="inline-tags" required="true"/>
  <p:option name="output-name-tag" required="false" select="''"/>
  <p:option name="output-word-tag" required="true"/>
  <p:option name="output-sentence-tag" required="true"/>
  <p:option name="word-attr" required="false" select="''"/>
  <p:option name="word-attr-val" required="false" select="''"/>
  <p:option name="sentence-attr" required="false" select="''"/>
  <p:option name="sentence-attr-val" required="false" select="''"/>
  <p:option name="output-ns" required="true"/>
  
  <p:option name="period-tags" required="false" select="''"/>
  <p:option name="comma-tags" required="false" select="''"/>
  <p:option name="end-sentence-tags" required="false" select="''"/>
  <p:option name="space-tags" required="false" select="''"/>

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>
  
  <!-- 1: run the java-based lexing step -->
  <px:break-detect>
    <p:with-option name="inline-tags" select="$inline-tags"/>
    <p:with-option name="output-name-tag" select="$output-name-tag"/>
    <p:with-option name="output-word-tag" select="$output-word-tag"/>
    <p:with-option name="word-attr" select="$word-attr"/>
    <p:with-option name="word-attr-val" select="$word-attr-val"/>
    <p:with-option name="output-sentence-tag" select="$output-sentence-tag"/>
    <p:with-option name="sentence-attr" select="$sentence-attr"/>
    <p:with-option name="sentence-attr-val" select="$sentence-attr-val"/>
    <p:with-option name="output-ns" select="$output-ns"/>
    <p:with-option name="period-tags" select="$period-tags" />
    <p:with-option name="comma-tags" select="$comma-tags"/>
    <p:with-option name="end-sentence-tags" select="$end-sentence-tags"/>
    <p:with-option name="space-tags" select="$space-tags"/>
  </px:break-detect>

  <cx:message message="java-based break detection done"/>
  
  <!-- 2: pull-down the <w> nodes when possible -->
  <p:xslt>
    <p:with-param name="markup" select="$output-word-tag"/>
    <p:with-param name="markup-attr" select="$word-attr"/>
    <p:with-param name="markup-attr-val" select="$word-attr-val"/>
    <p:with-param name="markup-ns" select="$output-ns"/>
    <p:input port="stylesheet">
      <p:document href="swap-nodes.xsl"/>
    </p:input>
  </p:xslt>
  <cx:message message="word nodes moved down"/>
  
  <!-- 3: merge all the identical nodes of a certain kind -->
  <px:repeat-merge repeat="3"/>
  <cx:message message="formatting nodes merged, iteration-1"/>
  
  <!-- 4: pull-down the <s> nodes when possible -->
  <p:xslt>
    <p:with-param name="markup" select="$output-sentence-tag"/>
    <p:with-param name="markup-attr" select="$sentence-attr"/>
    <p:with-param name="markup-attr-val" select="$sentence-attr-val"/>
    <p:with-param name="markup-ns" select="$output-ns"/>
    <p:input port="stylesheet">
      <p:document href="swap-nodes.xsl"/>
    </p:input>
  </p:xslt>
  <cx:message message="sentences nodes moved down"/>

  <!-- 5: merge all the identical nodes of a certain kind -->
  <px:repeat-merge repeat="3"/>
  <cx:message message="formatting nodes merged, iteration-2"/>
  
  <!-- 6: remove the 'mergeable' attribute -->
  <p:delete match="tmp:mergeable"/>
  <cx:message message="mergeable temporary attributes removed"/>
  
</p:declare-step>
