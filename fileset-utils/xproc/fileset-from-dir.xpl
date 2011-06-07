<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:err="http://www.w3.org/ns/xproc-error"
  xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="err px">
  
  <p:output port="result"/>
  <p:option name="path" required="true"/>
  <p:option name="recursive" select="'true'"/>
  <p:option name="include-filter"/>
  <p:option name="exclude-filter"/>
</p:declare-step>
