<p:declare-step type="px:break-detect"
		version="1.0" xmlns:p="http://www.w3.org/ns/xproc"	
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
		exclude-inline-prefixes="#all">
  
  <p:input port="source" primary="true" />
  <p:output port="result" primary="true" />

  <p:option name="inline-tags" required="true"/>
  <p:option name="output-word-tag" required="true"/>
  <p:option name="output-sentence-tag" required="true"/>
  <p:option name="tmp-ns" required="true"/>
  <p:option name="mergeable-attr" required="false" select="'mergeable'"/>
  <p:option name="period-tags" required="false" select="''"/>
  <p:option name="comma-tags" required="false" select="''"/>
  <p:option name="end-sentence-tags" required="false" select="''"/>
  <p:option name="space-tags" required="false" select="''"/>

</p:declare-step>