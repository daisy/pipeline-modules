<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:l="http://xproc.org/library"
                exclude-inline-prefixes="#all"
                type="px:zedai-validate" name="main">

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Validate a ZedAI (ANSI/NISO Z39.98-2012 Authoring and Interchange) document.</p>
		<p>Does not throw errors. Validation issues are reported through log messages.</p>
	</p:documentation>

	<p:input port="source"/>
	<p:output port="result"/>

	<p:option name="report-method" cx:type="log|error" select="'port'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Select the method used for reporting validation issues:</p>
			<dl>
				<dt>log</dt>
				<dd>Issues are reported through warning messages.</dd>
				<dt>error</dt>
				<dd>Issues are reported through error messages and also trigger an XProc error.</dd>
			</dl>
		</p:documentation>
	</p:option>
	<p:option name="allow-aural-css-attributes" select="false()" cx:as="xs:boolean">
		<p:documentation>
			<p>Whether the input contains aural CSS attributes (attributes with namespace
			"http://www.daisy.org/ns/pipeline/tts").</p>
		</p:documentation>
	</p:option>

	<p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl">
		<p:documentation>
			l:relax-ng-report
			px:report-errors
		</p:documentation>
	</p:import>
	<p:import href="http://www.daisy.org/pipeline/modules/css-speech/library.xpl">
		<p:documentation>
			px:css-speech-clean
		</p:documentation>
	</p:import>

	<p:choose px:progress="1/3">
		<p:when test="$allow-aural-css-attributes">
			<px:css-speech-clean>
				<p:documentation>Remove aural CSS attributes before validation</p:documentation>
			</px:css-speech-clean>
		</p:when>
		<p:otherwise>
			<p:identity/>
		</p:otherwise>
	</p:choose>

	<l:relax-ng-report name="validate" px:progress="1/3">
		<p:input port="schema">
			<p:document href="../schema/z3998-book-1.0-latest/z3998-book.rng"/>
		</p:input>
	</l:relax-ng-report>

	<px:report-errors px:progress="1/3">
		<p:input port="report">
			<p:pipe step="validate" port="report"/>
		</p:input>
		<p:with-option name="method" select="$report-method"/>
	</px:report-errors>

	<p:sink/>
	<p:identity cx:depends-on="validate">
		<p:input port="source">
			<p:pipe step="main" port="source"/>
		</p:input>
	</p:identity>

</p:declare-step>
