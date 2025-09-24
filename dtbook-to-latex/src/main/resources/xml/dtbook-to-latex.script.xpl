<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                type="px:dtbook-to-latex.script"
                px:input-filesets="dtbook"
                px:output-filesets="latex">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<h1 px:role="name">DTBook to LaTeX</h1>
		<p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into a LaTeX document.</p>
		<a px:role="homepage" href="http://daisy.github.io/pipeline/Get-Help/User-Guide/Scripts/dtbook-to-latex/">
			Online documentation
		</a>
	</p:documentation>

	<p:input port="source" primary="true" px:media-type="application/x-dtbook+xml">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2 px:role="name">DTBook</h2>
			<p px:role="desc">The DTBook 2005 XML file.</p>
		</p:documentation>
	</p:input>

	<p:option name="font-size" required="false" select="'17pt'">
		<p:documentation>
			<h2 px:role="name">Font size</h2>
			<p px:role="desc" xml:space="preserve">Font size for the generated LaTeX.

See also the documentation of the [extsizes
package](http://www.ctan.org/tex-archive/macros/latex/contrib/extsizes).</p>
		</p:documentation>
		<p:pipeinfo>
			<px:type>
				<choice>
					<value>12pt</value>
					<value>14pt</value>
					<value>17pt</value>
					<value>20pt</value>
					<value>25pt</value>
				</choice>
			</px:type>
		</p:pipeinfo>
	</p:option>

	<p:option name="result" px:output="result" px:type="anyDirURI" px:media-type="application/x-latex" required="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<h2 px:role="name">LaTeX</h2>
			<p px:role="desc">The output LaTeX document.</p>
		</p:documentation>
	</p:option>

	<cx:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl" type="application/xslt+xml">
		<p:documentation>
			pf:normalize-uri
		</p:documentation>
	</cx:import>

	<p:variable name="base-name" select="replace(replace(base-uri(/),'^.*/([^/]+)$','$1'),'\.[^\.]*$','')">
		<p:documentation>File name without extension</p:documentation>
	</p:variable>

	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="dtbook-to-latex.xsl"/>
		</p:input>
		<p:with-param name="fontsize" select="$font-size"/>
	</p:xslt>

	<p:store method="text">
		<p:with-option name="href" select="pf:normalize-uri(concat($result,'/',$base-name,'.tex'))"/>
	</p:store>

</p:declare-step>
