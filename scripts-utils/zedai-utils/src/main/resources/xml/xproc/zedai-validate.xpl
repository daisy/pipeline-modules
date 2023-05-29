<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:l="http://xproc.org/library"
                exclude-inline-prefixes="#all"
                type="px:zedai-validate">

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

	<p:import href="http://www.daisy.org/pipeline/modules/validation-utils/library.xpl">
		<p:documentation>
			l:relax-ng-report
			px:report-errors
		</p:documentation>
	</p:import>

	<l:relax-ng-report name="validate">
		<p:input port="schema">
			<p:document href="../schema/z3998-book-1.0-latest/z3998-book.rng"/>
		</p:input>
	</l:relax-ng-report>

	<px:report-errors>
		<p:input port="report">
			<p:pipe step="validate" port="report"/>
		</p:input>
		<p:with-option name="method" select="$report-method"/>
	</px:report-errors>

</p:declare-step>
