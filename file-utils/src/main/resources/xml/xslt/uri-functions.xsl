<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pf="http://www.daisy.org/ns/pipeline/functions" exclude-result-prefixes="#all"
    version="2.0">

    <xsl:function name="pf:tokenize-uri" as="xs:string*">
        <xsl:param name="uri" as="xs:string?"/>
        <!--
            Uses the regex defined in RFC3986 (Appendix B) to tokenize the URI in 5 parts:
            1. scheme
            2. authority
            3. path
            4. query
            5. fragment
        -->
        <xsl:analyze-string select="concat('X',$uri)"
            regex="^X(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?">
            <xsl:matching-substring>
                <xsl:sequence
                    select="(regex-group(2),regex-group(4),regex-group(5),regex-group(7),regex-group(9))"
                />
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="pf:recompose-uri" as="xs:string">
        <xsl:param name="tokens" as="xs:string*"/>
        <xsl:sequence
            select="string-join((
            if($tokens[1]) then ($tokens[1],':') else (),
            if($tokens[2]) then ('//',$tokens[2]) else (),
            $tokens[3],
            if($tokens[4]) then ('?',$tokens[4]) else (),
            if($tokens[5]) then ('#',$tokens[5]) else ()
            ),'')"
        />
    </xsl:function>

    <xsl:function name="pf:normalize-uri" as="xs:string">
        <xsl:param name="uri" as="xs:string?"/>
        <!--
            http://en.wikipedia.org/wiki/URL_normalization
            - path segment normalization
            - TODO case normalization
            - TODO percent-encoding normalization
            - TODO default http port
        -->
        <xsl:variable name="tokens" select="pf:tokenize-uri($uri)" as="xs:string*"/>
        <xsl:sequence
            select="pf:recompose-uri(($tokens[1],$tokens[2],pf:normalize-path($tokens[3]),$tokens[4],$tokens[5]))"
        />
    </xsl:function>

    <xsl:function name="pf:relativize-uri" as="xs:string">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:param name="base" as="xs:string?"/>
        <xsl:variable name="uri-tokens" select="pf:tokenize-uri(pf:normalize-uri($uri))"/>
        <xsl:variable name="base-tokens" select="pf:tokenize-uri(pf:normalize-uri($base))"/>

        <xsl:choose>
            <xsl:when
                test="(not($uri-tokens[1]) or $uri-tokens[1]=$base-tokens[1]) and (not($uri-tokens[2]) or $uri-tokens[2]=$base-tokens[2])">
                <xsl:sequence
                    select="pf:recompose-uri(('','',pf:relativize-path($uri-tokens[3],$base-tokens[3]),$uri-tokens[4],$uri-tokens[5]))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="pf:recompose-uri($uri-tokens)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="pf:normalize-path" as="xs:string?">
        <xsl:param name="path" as="xs:string?"/>
        <xsl:variable name="normalized" as="xs:string?"
            select="
            replace(
                replace(
                    replace(
                        replace(
                            replace($path,'^(\.(/|$))+','')
                        ,'/(\.(/|$))+','/')
                    ,'/+','/')
                ,'(^|/)\.\.$','$1../')
            ,'^/\.\./$','/')
            "/>
        <xsl:sequence
            select="
            if (matches($normalized,'([^/]|\.[^/]|[^/]\.|[^/]{3,})/\.\./')) then
            pf:normalize-path(replace($normalized,'([^/]|\.[^/]|[^/]\.|[^/]{3,})/\.\./',''))
            else 
            $normalized"
        />
    </xsl:function>

    <xsl:function name="pf:relativize-path" as="xs:string">
        <xsl:param name="path" as="xs:string?"/>
        <xsl:param name="base" as="xs:string?"/>

        <xsl:choose>
            <xsl:when test="starts-with($path,'/')">
                <xsl:variable name="path-segments" select="tokenize($path, '/')"/>
                <xsl:variable name="base-segments" select="tokenize($base, '/')[position()!=last()]"/>
                <xsl:variable name="common-prefix-length"
                    select="
                    (for $i in 1 to count($base-segments) return
                         if($base-segments[$i] eq $path-segments[$i]) then () else $i -1
                    ,count($base-segments))[1]"/>
                <xsl:variable name="upSteps" select="count($base-segments) -$common-prefix-length"/>
                <xsl:sequence
                    select="string-join((
                    for $i in 1 to $upSteps
                        return '..',
                    for $i in 1 to count($path-segments) - $common-prefix-length 
                        return $path-segments[$common-prefix-length + $i]
                    ),'/')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="pf:longest-common-uri">
        <xsl:param name="uris"/>
        <xsl:choose>
            <xsl:when test="count($uris)=1">
                <xsl:value-of select="$uris"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="a" select="for $part in tokenize(pf:normalize-uri(replace($uris[1],'/+','SLASH|/')),'/') return replace($part,'SLASH\|$','/')"/>
                <xsl:variable name="b" select="for $part in tokenize(pf:normalize-uri(replace($uris[2],'/+','SLASH|/')),'/') return replace($part,'SLASH\|$','/')"/>
                <xsl:variable name="longest-common" select="for $i in 1 to count($a) return if ($a[$i]=$b[$i]) then $a[$i] else '	'"/>
                <xsl:variable name="longest-common" select="for $i in 1 to count($a) return if ($longest-common[position()&lt;=$i]='	') then () else $longest-common[$i]"/>
                <xsl:variable name="longest-common" select="concat($longest-common[1],if (matches($longest-common[1],'^\w+:/$') and not(matches($longest-common[1],'^file:/'))) then '/' else '',string-join($longest-common[position()&gt;1],''))"/>
                <xsl:value-of select="string-join($longest-common,' | ')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
