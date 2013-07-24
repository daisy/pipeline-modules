<p:declare-step type="px:repeat-merge" version="1.0"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:px="http://www.daisy.org/ns/pipeline/xproc"	
		xmlns:cx="http://xmlcalabash.com/ns/extensions">
  
  <p:option name="repeat" required="true"/>
  
  <p:input port="source" primary="true" sequence="false"/>
  <p:output port="result" primary="true" sequence="false"/>

  <p:choose>
    <p:when test="$repeat = '0'">
      <p:identity/>
    </p:when>
    <p:otherwise>
      <p:xslt>
	<p:input port="parameters">
	  <p:empty/>
	</p:input>
	<p:input port="stylesheet">
	  <p:document href="merge-nodes.xsl"/>
	</p:input>
      </p:xslt>
      <px:repeat-merge>
	<p:with-option name="repeat" select="$repeat - 1"/>
      </px:repeat-merge>
    </p:otherwise>
  </p:choose>
</p:declare-step>