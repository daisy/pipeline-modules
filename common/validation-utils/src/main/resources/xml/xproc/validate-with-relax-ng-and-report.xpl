<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:err="http://www.w3.org/ns/xproc-error"
                xmlns:l="http://xproc.org/library"
                type="px:validate-with-relax-ng-and-report"
                name="validate-with-relax-ng-and-report">

    <p:input port="source" primary="true"/>
    <p:input port="schema"/>
    <p:output port="result" primary="true"/>
    <p:option name="assert-valid" select="'true'" cx:as="xs:string"/>
    <p:option name="dtd-attribute-values" select="'false'" cx:as="xs:string"/>
    <p:option name="dtd-id-idref-warnings" select="'false'" cx:as="xs:string"/>

    <p:import href="relax-ng-report.xpl">
        <p:documentation>
            l:relax-ng-report
        </p:documentation>
    </p:import>
    <p:import href="report-errors.xpl">
        <p:documentation>
            px:report-errors
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:error
        </p:documentation>
    </p:import>

    <l:relax-ng-report name="validate">
        <p:input port="source">
            <p:pipe step="validate-with-relax-ng-and-report" port="source"/>
        </p:input>
        <p:input port="schema">
            <p:pipe step="validate-with-relax-ng-and-report" port="schema"/>
        </p:input>
        <p:with-option name="dtd-attribute-values" select="$dtd-attribute-values"/>
        <p:with-option name="dtd-id-idref-warnings" select="$dtd-id-idref-warnings"/>
    </l:relax-ng-report>

    <p:choose>
        <p:variable name="failed" cx:as="xs:boolean" select="exists(collection()//c:error)">
            <p:pipe step="validate" port="report"/>
        </p:variable>
        <p:when test="$failed and $assert-valid='true'">
            <px:report-errors method="error">
                <p:input port="report">
                    <p:pipe step="validate" port="report"/>
                </p:input>
            </px:report-errors>
        </p:when>
        <p:when test="$failed">
            <px:report-errors method="log">
                <p:input port="report">
                    <p:pipe step="validate" port="report"/>
                </p:input>
            </px:report-errors>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>

</p:declare-step>
