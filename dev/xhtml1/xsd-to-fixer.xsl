<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions" exclude-result-prefixes="#all" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:variable name="htmlns" select="'http://www.w3.org/1999/xhtml'"/>
    <xsl:variable name="obsolete" select="document('obsolete-html5.xml')/*"/>

    <xsl:template match="/*">
        <xsl:element name="xsl:stylesheet">
            <xsl:attribute name="version" select="'2.0'"/>
            <xsl:namespace name="h" select="$htmlns"/>
            <xsl:attribute name="exclude-result-prefixes" select="'#all'"/>
            <xsl:text>
                
</xsl:text>
            <xsl:element name="xsl:output">
                <xsl:attribute name="indent" select="'yes'"/>
                <xsl:attribute name="method" select="'xml'"/>
            </xsl:element>
            <xsl:text>
                
</xsl:text>
            <xsl:element name="xsl:template">
                <xsl:attribute name="match" select="'/'"/>
                <xsl:element name="xsl:for-each">
                    <xsl:attribute name="select" select="'*|text()|processing-instruction()|comment()'"/>
                    <xsl:element name="xsl:copy">
                        <xsl:element name="xsl:apply-templates">
                            <xsl:attribute name="select" select="'.'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:text>
                
</xsl:text>
            <xsl:element name="xsl:template">
                <xsl:attribute name="match" select="'text()|processing-instruction()|comment()'"/>
                <xsl:element name="xsl:copy-of">
                    <xsl:attribute name="select" select="'.'"/>
                </xsl:element>
            </xsl:element>
            <xsl:text>
                
</xsl:text>
            <xsl:for-each select="/*/xs:element">
                <xsl:variable name="allowedAttributes" select="f:make-attribute-list(.,/*)"/>
                <xsl:variable name="allowedElements" select="f:make-element-list(.,/*)"/>
                <xsl:element name="xsl:template">
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="match" select="concat('h:',@name)"/>
                    <xsl:element name="xsl:copy-of">
                        <xsl:attribute name="select"
                            select="concat(string-join(for $a in ($allowedAttributes) return concat('@',$a),'|'),(if (count($allowedAttributes) &gt; 0) then '|' else ''),&quot;@*[not(namespace-uri()=('','&quot;,$htmlns,&quot;')) or starts-with(local-name(),'data-')]&quot;)"
                        />
                    </xsl:element>
                    <xsl:element name="xsl:for-each">
                        <xsl:attribute name="select" select="'*|text()|comment()'"/>
                        <xsl:element name="xsl:choose">
                            <xsl:element name="xsl:when">
                                <xsl:attribute name="test"
                                    select="concat(string-join(for $e in ($allowedElements) return concat('self::h:',$e),'|'),(if (count($allowedElements) &gt; 0) then '|' else ''),&quot;self::*[not(namespace-uri()=('','&quot;,$htmlns,&quot;'))]&quot;)"/>
                                <xsl:element name="xsl:copy">
                                    <xsl:element name="xsl:apply-templates">
                                        <xsl:attribute name="select" select="'.'"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="xsl:when">
                                <xsl:attribute name="test" select="'self::*'"/>
                                <xsl:element name="xsl:variable">
                                    <xsl:attribute name="name" select="'replaceWith'"/>
                                    <xsl:attribute name="select"
                                        select="concat(&quot;if (not(namespace-uri()=('','&quot;,$htmlns,&quot;'))) then '' else &quot;,
                                        string-join((for $e in ($obsolete/elements/*[@replaceWith]) return concat(&quot;if (local-name()='&quot;,$e/local-name(),&quot;') then '&quot;,$e/@replaceWith,&quot;' else &quot;)),'')
                                        ,&quot;''&quot;)"
                                    />
                                </xsl:element>
                                <xsl:element name="xsl:choose">
                                    <xsl:element name="xsl:when">
                                        <xsl:attribute name="test"
                                            select="concat(&quot;namespace-uri()=('','&quot;,$htmlns,&quot;') and $replaceWith=('&quot;,string-join($allowedElements,&quot;','&quot;),&quot;')&quot;)"/>
                                        <xsl:element name="xsl:element">
                                            <xsl:attribute name="name" select="'{$replaceWith}'"/>
                                            <xsl:attribute name="namespace" select="$htmlns"/>
                                            <xsl:choose>
                                                <xsl:when test="/*/xs:element/@name"/>
                                            </xsl:choose>
                                            <xsl:if test="count($allowedElements) &gt; 0">
                                                <xsl:element name="xsl:choose">
                                                    <xsl:for-each select="$allowedElements">
                                                        <xsl:element name="xsl:when">
                                                            <xsl:attribute name="test" select="concat(&quot;$replaceWith='&quot;,.,&quot;'&quot;)"/>
                                                            <xsl:element name="xsl:call-template">
                                                                <xsl:attribute name="name" select="."/>
                                                            </xsl:element>
                                                        </xsl:element>
                                                    </xsl:for-each>
                                                    <xsl:element name="xsl:otherwise"/>
                                                </xsl:element>
                                            </xsl:if>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="xsl:otherwise">
                                        <xsl:choose>
                                            <xsl:when test="'span'=$allowedElements">
                                                <xsl:element name="span" namespace="{$htmlns}">
                                                    <xsl:element name="xsl:call-template">
                                                        <xsl:attribute name="name" select="'span'"/>
                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:when>
                                            <xsl:when test="'div'=$allowedElements">
                                                <xsl:element name="div" namespace="{$htmlns}">
                                                    <xsl:element name="xsl:call-template">
                                                        <xsl:attribute name="name" select="'div'"/>
                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:when>
                                            <xsl:when test="count($allowedElements) &gt; 0">
                                                <xsl:element name="{$allowedElements[1]}" namespace="{$htmlns}">
                                                    <xsl:element name="xsl:call-template">
                                                        <xsl:attribute name="name" select="$allowedElements[1]"/>
                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:element name="xsl:apply-templates">
                                                    <xsl:attribute name="select" select="'text()|comment()'"/>
                                                </xsl:element>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="xsl:otherwise">
                                <xsl:element name="xsl:copy">
                                    <xsl:element name="xsl:apply-templates">
                                        <xsl:attribute name="select" select="'.'"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:text>
                
</xsl:text>
            </xsl:for-each>
            <xsl:text>
                
</xsl:text>

        </xsl:element>
    </xsl:template>

    <xsl:function name="f:make-attribute-list">
        <xsl:param name="element"/>
        <xsl:param name="document"/>
        <xsl:variable name="from-xsd" select="f:make-attribute-list-from-xsd($element,$document)"/>
        <xsl:variable name="from-obsolete" select="$obsolete/attributes/*[local-name()=$element/@name]/@*/local-name()"/>
        <xsl:copy-of select="for $a in ($from-xsd) return if ($a=$from-obsolete) then () else $a"/>
    </xsl:function>

    <xsl:function name="f:make-attribute-list-from-xsd">
        <xsl:param name="element"/>
        <xsl:param name="xsd"/>
        <xsl:copy-of
            select="$element//xs:attribute/@name
            | (for $a in ($xsd/xs:attributeGroup[@name=$element//xs:attributeGroup/@ref]) return f:make-attribute-list-from-xsd($a,$xsd))"
        />
    </xsl:function>

    <xsl:function name="f:make-element-list">
        <xsl:param name="element"/>
        <xsl:param name="document"/>
        <xsl:variable name="from-xsd" select="f:make-element-list-from-xsd($element,$document)"/>
        <xsl:variable name="from-obsolete" select="$obsolete/elements/*/local-name()"/>
        <xsl:copy-of select="for $e in ($from-xsd) return if ($e=$from-obsolete) then () else $e"/>
    </xsl:function>

    <xsl:function name="f:make-element-list-from-xsd">
        <xsl:param name="element"/>
        <xsl:param name="document"/>
        <xsl:copy-of
            select="$element//xs:element/@ref
                | (for $e in ($document/xs:complexType[@name=$element//xs:extension/@base] | $document/xs:group[@name=$element//xs:group/@ref]) return f:make-element-list-from-xsd($e,$document))"
        />
    </xsl:function>

</xsl:stylesheet>
