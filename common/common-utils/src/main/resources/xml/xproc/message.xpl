<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:x="http://www.emc.com/documentum/xml/xproc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                exclude-inline-prefixes="#all"
                type="px:message" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Example usage:</p>
        <pre xml:space="preserve">
            &lt;px:message message="The value '$1' is an invalid font color. Will use black instead." severity="WARN"&gt;
                &lt;p:with-param name="param1" select="$color"/&gt;
            &lt;/px:message&gt;
        </pre>
    </p:documentation>

    <p:input port="source" primary="true" sequence="true">
        <p:empty/>
    </p:input>
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:option name="severity" select="'INFO'"/>                  <!-- one of either: WARN, INFO, DEBUG. Defaults to "INFO". Use px:error to throw errors. -->
    <p:option name="message" required="true" cx:as="xs:string"/> <!-- message to be logged. $1, $2 etc will be replaced with the contents of param1, param2 etc. -->
    <p:option name="param1" select="''" cx:as="xs:string"/>
    <p:option name="param2" select="''" cx:as="xs:string"/>
    <p:option name="param3" select="''" cx:as="xs:string"/>
    <p:option name="param4" select="''" cx:as="xs:string"/>
    <p:option name="param5" select="''" cx:as="xs:string"/>
    <p:option name="param6" select="''" cx:as="xs:string"/>
    <p:option name="param7" select="''" cx:as="xs:string"/>
    <p:option name="param8" select="''" cx:as="xs:string"/>
    <p:option name="param9" select="''" cx:as="xs:string"/>
    <!-- in the unlikely event that you need more parameters you'll have to format the message string yourself -->

    <p:group>
        <p:variable name="formatted-message"
                    select="replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              $message,
                              '\$1',replace($param1,'\$','\\\$')),
                              '\$2',replace($param2,'\$','\\\$')),
                              '\$3',replace($param3,'\$','\\\$')),
                              '\$4',replace($param4,'\$','\\\$')),
                              '\$5',replace($param5,'\$','\\\$')),
                              '\$6',replace($param6,'\$','\\\$')),
                              '\$7',replace($param7,'\$','\\\$')),
                              '\$8',replace($param8,'\$','\\\$')),
                              '\$9',replace($param9,'\$','\\\$'))"/>
        <p:identity>
            <p:input port="source">
                <p:pipe step="main" port="source"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:xpath-context>
                <p:empty/>
            </p:xpath-context>
            <p:when test="$severity='WARN'">
                <p:identity px:message-severity="WARN" px:message="{$formatted-message}"/>
            </p:when>
            <p:when test="$severity='DEBUG'">
                <p:identity px:message-severity="DEBUG" px:message="{$formatted-message}"/>
            </p:when>
            <p:otherwise>
                <p:identity px:message-severity="INFO" px:message="{$formatted-message}"/>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:identity name="result"/>

</p:declare-step>
