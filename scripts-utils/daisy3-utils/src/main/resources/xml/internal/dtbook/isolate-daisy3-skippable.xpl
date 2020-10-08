<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                type="px:daisy3-isolate-skippable" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Break up sentences into sub-sentences that do not contain skippable elements.</p>
    </p:documentation>

    <p:input port="source" primary="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>The input DTBook</p>
      </p:documentation>
    </p:input>
    <p:input port="sentence-ids">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>List of sentences as a <code>d:sentences</code> document with a <code>d:sentence</code>
        child for each sentence. The <code>d:sentence</code> elements point to the respective DTBook
        elements with an <code>id</code> attribute.</p>
      </p:documentation>
    </p:input>

    <p:output port="result" primary="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>The result DTBook.</p>
        <p>For every sentence element that contains one or more skippable elements, that is
        <code>pagenum</code>, <code>noteref</code>, <code>annoref</code>, <code>linenum</code> or
        <code>math</code>,</p>
        <ul>
          <li>the skippable elements do not share any ancestors with other nodes in the sentence
          (nodes that are not themselves ancestors of the skippables), and</li>
          <li>the sentence element has no (non-whitespace-only) child text nodes.</li>
        </ul>
        <p>The reading order is preserved, and apart from elements that are broken up and wrapper
        <code>span</code> elements that are inserted, the structure of the DTBook is preserved.</p>
      </p:documentation>
      <p:pipe port="result" step="isolate-result"/>
    </p:output>
    <p:output port="skippable-ids">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>List of skippable elements as a <code>dtb:skippables</code> document with a
        <code>dtb:skippable</code> child for each skippable element. The <code>dtb:skippable</code>
        elements point to the respective DTBook elements with an <code>id</code> attribute.</p>
      </p:documentation>
      <p:pipe port="result" step="skippable"/>
    </p:output>

    <p:option name="id-prefix" select="''"/>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
      <p:documentation>
	px:add-ids
      </p:documentation>
    </p:import>

    <px:add-ids name="add-ids-for-skippables"
		match="dtb:pagenum|dtb:noteref|dtb:annoref|dtb:linenum|math:math">
      <p:documentation>Make sure that skippable elements have an id
      attribute. isolate-daisy3-skippable.xsl depends on this.</p:documentation>
      <p:input port="source">
	<p:pipe step="main" port="source"/>
      </p:input>
    </px:add-ids>
    <p:sink/>

    <p:xslt name="isolate-xslt">
      <p:input port="source">
	<p:pipe step="add-ids-for-skippables" port="result"/>
	<p:pipe port="sentence-ids" step="main"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="isolate-daisy3-skippable.xsl"/>
      </p:input>
      <p:with-param name="id-prefix" select="$id-prefix"/>
    </p:xslt>
    <p:delete match="dtb:skippable" name="isolate-result"/>

    <p:identity>
      <p:input port="source" select="//dtb:skippable">
	<p:pipe port="result" step="isolate-xslt"/>
      </p:input>
    </p:identity>
    <p:wrap-sequence name="skippable" wrapper="dtb:skippables"/>

</p:declare-step>
