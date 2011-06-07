<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">
  
  <p:input port="source" sequence="true"/>
  <p:output port="result"/>
  
  <!--<p:declare-step type="px:join-manifests" name="join-manifests">
    <p:input port="source" sequence="true"/>
    <p:output port="result"/>
    <p:wrap-sequence wrapper="c:manifest"/>
    <p:unwrap match="/c:manifest/c:manifest"/>
    <p:choose>
    <p:when test="//c:entry">
    <p:label-elements match="c:entry" attribute="href"
    label="resolve-uri(@href,base-uri())" replace="true"/>
    <p:label-elements match="c:manifest" attribute="xml:base"
    label="
    (
    for $pref in
    reverse(
    for $uri in //@href
    return
    for $i in 1 to count(tokenize($uri,'/'))
    return concat(string-join(
    for $p in 1 to $i return tokenize($uri,'/')[$p]
    ,'/'),'/')
    )
    return
    if (every $h in //@href satisfies starts-with($h,$pref)) then $pref else ()
    )[1]
    "
    replace="true"/>
    <p:label-elements match="c:entry" attribute="xml:base" label="/*/@xml:base"
    replace="true"/>
    <p:label-elements match="c:entry" attribute="href"
    label="if (starts-with(@href,base-uri())) then substring-after(@href,base-uri()) else @href"
    replace="true"/>
    <p:add-xml-base/>
    </p:when>
    <p:otherwise>
    <p:identity/>
    </p:otherwise>
    </p:choose>
    </p:declare-step>-->
</p:declare-step>
