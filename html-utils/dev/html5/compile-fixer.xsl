<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions" xmlns:d="http://www.daisy.org/ns/pipeline/data" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output indent="yes"/>

    <xsl:param name="debug" select="false()"/>

    <xsl:variable name="htmlns" select="'http://www.w3.org/1999/xhtml'"/>
    <xsl:variable name="functionns" select="'http://www.daisy.org/ns/pipeline/internal-functions'"/>
    <xsl:variable name="obsolete" select="document('obsolete-html5.xml')/*"/>

    <xsl:template match="/*">
        <xsl:element name="xsl:stylesheet">
            <xsl:attribute name="version" select="'2.0'"/>
            <xsl:namespace name="h" select="$htmlns"/>
            <xsl:namespace name="f" select="$functionns"/>
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
            <xsl:for-each select="/*/d:element">
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
                                    <xsl:if test="$debug">
                                        <xsl:element name="xsl:comment">
                                            <xsl:attribute name="select" select="&quot;concat(local-name(),' is allowed; was copied')&quot;"/>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:element>
                            </xsl:element>
                            <xsl:if test="d:element/@ref='transparent'">
                                <xsl:element name="xsl:when">
                                    <xsl:attribute name="test" select="'self::* and local-name()=f:recursive-transparency(.)'"/>
                                    <xsl:element name="xsl:copy">
                                        <xsl:element name="xsl:apply-templates">
                                            <xsl:attribute name="select" select="'.'"/>
                                        </xsl:element>
                                        <xsl:if test="$debug">
                                            <xsl:element name="xsl:comment">
                                                <xsl:attribute name="select" select="&quot;concat(local-name(),' is allowed transparently; was copied')&quot;"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
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
                                        <xsl:attribute name="test" select="concat(&quot;namespace-uri()=('','&quot;,$htmlns,&quot;') and not($replaceWith='') and $replaceWith=('&quot;,string-join($allowedElements,&quot;','&quot;),&quot;')&quot;)"/>
                                        <xsl:element name="xsl:element">
                                            <xsl:attribute name="name" select="'{$replaceWith}'"/>
                                            <xsl:attribute name="namespace" select="$htmlns"/>
                                            <xsl:choose>
                                                <xsl:when test="count($allowedElements) &gt; 0">
                                                    <xsl:element name="xsl:choose">
                                                        <xsl:for-each select="$allowedElements">
                                                            <xsl:element name="xsl:when">
                                                                <xsl:attribute name="test" select="concat(&quot;$replaceWith='&quot;,.,&quot;'&quot;)"/>
                                                                <xsl:element name="xsl:call-template">
                                                                    <xsl:attribute name="name" select="."/>
                                                                </xsl:element>
                                                                <xsl:if test="$debug">
                                                                    <xsl:element name="xsl:comment">
                                                                        <xsl:attribute name="select" select="&quot;concat(local-name(),' was a HTML4 element that was replaced by a HTML5 element')&quot;"/>
                                                                    </xsl:element>
                                                                </xsl:if>
                                                            </xsl:element>
                                                        </xsl:for-each>
                                                        <xsl:element name="xsl:otherwise">
                                                            <xsl:if test="$debug">
                                                                <xsl:element name="xsl:comment">
                                                                    <xsl:attribute name="select" select="&quot;concat(local-name(),' was a HTML4 element with no replacement')&quot;"/>
                                                                </xsl:element>
                                                            </xsl:if>
                                                            <xsl:element name="xsl:apply-templates">
                                                                <xsl:attribute name="select" select="'text()|comment()'"/>
                                                            </xsl:element>
                                                        </xsl:element>
                                                    </xsl:element>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:element name="xsl:apply-templates">
                                                        <xsl:attribute name="select" select="'text()|comment()'"/>
                                                    </xsl:element>
                                                    <xsl:if test="$debug">
                                                        <xsl:element name="xsl:comment">
                                                            <xsl:attribute name="select" select="&quot;concat(local-name(),' was a HTML4 element with no replacement')&quot;"/>
                                                        </xsl:element>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="xsl:otherwise">
                                        <xsl:element name="xsl:variable">
                                            <xsl:attribute name="name" select="'transparentAllowedElements'"/>
                                            <xsl:variable name="joinedAllowedElements" select="string-join($allowedElements,&quot;','&quot;)"/>
                                            <xsl:variable name="joinedAllowedElements" select="if (string-length($joinedAllowedElements)&gt;0) then concat(&quot;('&quot;,$joinedAllowedElements,&quot;')&quot;) else '()'"/>
                                            <xsl:variable name="recursiveTransparency" select="if (d:element/@ref='transparent') then 'f:recursive-transparency(.)' else '()'"/>
                                            <xsl:attribute name="select" select="concat('(',$recursiveTransparency,',',$joinedAllowedElements,')')"/>
                                        </xsl:element>
                                        <xsl:element name="xsl:choose">
                                            <xsl:element name="xsl:when">
                                                <xsl:attribute name="test" select="&quot;'div'=$transparentAllowedElements&quot;"/>
                                                <xsl:element name="div" namespace="{$htmlns}">
                                                    <xsl:element name="xsl:call-template">
                                                        <xsl:attribute name="name" select="'div'"/>
                                                    </xsl:element>
                                                    <xsl:if test="$debug">
                                                        <xsl:element name="xsl:comment">
                                                            <xsl:attribute name="select" select="&quot;concat(local-name(),': div was allowed directly or transparently')&quot;"/>
                                                        </xsl:element>
                                                    </xsl:if>
                                                </xsl:element>
                                            </xsl:element>
                                            <xsl:element name="xsl:when">
                                                <xsl:attribute name="test" select="&quot;'span'=$transparentAllowedElements&quot;"/>
                                                <xsl:element name="span" namespace="{$htmlns}">
                                                    <xsl:element name="xsl:call-template">
                                                        <xsl:attribute name="name" select="'span'"/>
                                                    </xsl:element>
                                                    <xsl:if test="$debug">
                                                        <xsl:element name="xsl:comment">
                                                            <xsl:attribute name="select" select="&quot;concat(local-name(),': span was allowed directly or transparently')&quot;"/>
                                                        </xsl:element>
                                                    </xsl:if>
                                                </xsl:element>
                                            </xsl:element>
                                            <xsl:element name="xsl:when">
                                                <xsl:attribute name="test" select="&quot;count($transparentAllowedElements) &gt; 0&quot;"/>
                                                <xsl:element name="xsl:element">
                                                    <xsl:attribute name="name" select="'{($transparentAllowedElements)[1]}'"/>
                                                    <xsl:attribute name="namespace" select="$htmlns"/>
                                                    <xsl:element name="xsl:choose">
                                                        <xsl:for-each select="/*/d:element/@name">
                                                            <xsl:element name="xsl:when">
                                                                <xsl:attribute name="test" select="concat(&quot;'&quot;,.,&quot;'=($transparentAllowedElements)[1]&quot;)"/>
                                                                <xsl:element name="xsl:call-template">
                                                                    <xsl:attribute name="name" select="."/>
                                                                </xsl:element>
                                                                <xsl:if test="$debug">
                                                                    <xsl:element name="xsl:comment">
                                                                        <xsl:attribute name="select" select="concat(&quot;concat(local-name(),': &quot;,.,&quot; was allowed directly or transparently')&quot;)"/>
                                                                    </xsl:element>
                                                                </xsl:if>
                                                            </xsl:element>
                                                        </xsl:for-each>
                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:element>
                                            <xsl:element name="xsl:otherwise">
                                                <xsl:element name="xsl:apply-templates">
                                                    <xsl:attribute name="select" select="'text()|comment()'"/>
                                                </xsl:element>
                                                <xsl:if test="$debug">
                                                    <xsl:element name="xsl:comment">
                                                        <xsl:attribute name="select" select="&quot;concat(local-name(),' was a disallowed element with no replacement')&quot;"/>
                                                    </xsl:element>
                                                </xsl:if>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="xsl:otherwise">
                                <xsl:element name="xsl:copy">
                                    <xsl:element name="xsl:apply-templates">
                                        <xsl:attribute name="select" select="'.'"/>
                                    </xsl:element>
                                    <xsl:if test="$debug">
                                        <xsl:element name="xsl:comment">
                                            <xsl:attribute name="select" select="&quot;concat(local-name(),' was copied directly')&quot;"/>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:text>
                
</xsl:text>
            </xsl:for-each>

            <xsl:element name="xsl:function">
                <xsl:attribute name="name" select="'f:recursive-transparency'"/>
                <xsl:element name="xsl:param">
                    <xsl:attribute name="name" select="'element'"/>
                </xsl:element>
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name" select="'name'"/>
                    <xsl:attribute name="select" select="'local-name($element)'"/>
                </xsl:element>
                <xsl:element name="xsl:choose">
                    <xsl:for-each select="/*/d:element">
                        <xsl:element name="xsl:when">
                            <xsl:attribute name="test" select="concat(&quot;$name='&quot;,@name,&quot;'&quot;)"/>
                            <xsl:variable name="element-list" select="f:make-element-list(.,/*)"/>
                            <xsl:variable name="transparent-recursion" select="if (d:element/@ref='transparent') then 'f:recursive-transparency($element/..)' else '()'"/>
                            <xsl:element name="xsl:sequence">
                                <xsl:attribute name="select"
                                    select="concat(&quot;(&quot;,$transparent-recursion,&quot;),(&quot;,if (count($element-list) = 0) then &quot;()&quot; else concat(&quot;('&quot;,string-join($element-list,&quot;','&quot;),&quot;')&quot;),&quot;)&quot;)"
                                />
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="xsl:otherwise">
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select" select="'()'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

            <xsl:text>
                
</xsl:text>

        </xsl:element>
    </xsl:template>

    <xsl:function name="f:make-attribute-list">
        <xsl:param name="element"/>
        <xsl:param name="document"/>
        <xsl:variable name="from-xsd" select="f:make-attribute-list-from-html5($element,$document)"/>
        <xsl:variable name="from-obsolete" select="$obsolete/attributes/*[local-name()=$element/@name]/@*/local-name()"/>
        <xsl:copy-of select="for $a in ($from-xsd) return if ($a=$from-obsolete) then () else $a"/>
    </xsl:function>

    <xsl:function name="f:make-attribute-list-from-html5">
        <xsl:param name="element"/>
        <xsl:param name="html5"/>
        <xsl:copy-of select="$element//d:attribute/@name
            | (for $a in ($html5/d:attribute-set[@name=$element//d:attribute/@ref]) return f:make-attribute-list-from-html5($a,$html5))"/>
    </xsl:function>

    <xsl:function name="f:make-element-list">
        <xsl:param name="element"/>
        <xsl:param name="document"/>
        <xsl:variable name="from-html5" select="f:make-element-list-from-html5($element,$document)"/>
        <xsl:variable name="from-obsolete" select="$obsolete/elements/*/local-name()"/>
        <xsl:copy-of select="for $e in ($from-html5) return if ($e=$from-obsolete) then () else $e"/>
    </xsl:function>

    <xsl:function name="f:make-element-list-from-html5">
        <xsl:param name="element"/>
        <xsl:param name="document"/>
        <xsl:copy-of select="$element//d:element/@name
            | (for $e in ($document/d:content[@name=$element//d:element/@ref]) return f:make-element-list-from-html5($e,$document))"/>
    </xsl:function>

</xsl:stylesheet>
