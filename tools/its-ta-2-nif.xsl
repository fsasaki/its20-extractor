<!-- XSLT 2.0 stylesheet to convert ITS 2.0 text analysis annotation local markup from HTML to NIF, as defined at http://www.w3.org/TR/its20/#conversion-to-nif
Copyright Felix Sasaki fsasaki@w3.org 2013
For further information about ITS 2.0 text analysis annotation see http://www.w3.org/TR/its20/#textanalysis
For further information about NIF see http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core
License: http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
USAGE:
- Input is 1) XHTML or HTML5 parsed into a DOM e.g. via https://github.com/kosek/html5-its-tools, 2) a parameter "base-uri" of the document.
  If ommitted a dummy URI http://example.com/exampledoc.html is used.
- Output is an RDF/XML document containing RDF statements for each element that provides text analysis annotation local markup.
Note: white space is not stripped. If that is needed you should pre-process the document.

$Id: its-ta-2-nif.xsl,v 1.19 2013-05-26 16:47:34 fsasaki Exp $
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:nif="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#">
	<xsl:include href="stripping.xsl"/>
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:param name="base-uri">http://example.com/exampledoc.html</xsl:param>
	<xsl:variable name="whiteSpaceStripped">
		<xsl:apply-templates select="/" mode="stripWS"/>
	</xsl:variable>
	<xsl:variable name="referenceContext"
		select="concat($base-uri,'#char=0,',string-length($whiteSpaceStripped))"/>
	<xsl:template match="*|@*" mode="get-full-path">
		<xsl:apply-templates select="parent::*" mode="get-full-path"/>
		<xsl:text>/</xsl:text>
		<xsl:if test="count(. | ../@*) = count(../@*)">@</xsl:if>
		<xsl:value-of select="name()"/>
		<xsl:if test="self::* and parent::*"><xsl:text>%5B</xsl:text><xsl:number/><xsl:text>%5D</xsl:text></xsl:if>
		<xsl:if test="not(child::*)">/text()%5B1%5D</xsl:if>
	</xsl:template>
	<xsl:template match="/">
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#">
			<rdf:Description rdf:about="{$referenceContext}">
				<nif:sourceUrl rdf:resource="{$base-uri}"/>
				<nif:isString><xsl:value-of select="$whiteSpaceStripped"/></nif:isString>
				<rdf:type rdf:resource="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#Context"/>
			</rdf:Description>
			<xsl:apply-templates select="$whiteSpaceStripped" mode="processStripped"/>
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="*" mode="processStripped">
		<xsl:variable name="element-path"><xsl:apply-templates select="." mode="get-full-path"/></xsl:variable>
		<xsl:variable name="preceding">
			<xsl:value-of select="preceding::text()"/>
		</xsl:variable>
		<xsl:variable name="offset-start" select="string-length($preceding)"/>
		<xsl:variable name="offset-end" select="$offset-start + string-length(.)"/>
		<xsl:if test="@its-ta-confidence or @its-ta-class-ref or @its-ta-ident-ref">
 			<rdf:Description rdf:about="{concat($base-uri,'#xpath(',$element-path,')')}">
 				<nif:convertedFrom rdf:resource="{concat($base-uri,'#char=',$offset-start,',',$offset-end)}"/>
			</rdf:Description>
			<rdf:Description rdf:about="{concat($base-uri,'#char=',$offset-start,',',$offset-end)}">
				<rdf:type rdf:resource="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#RFC5147String"/>
				<nif:anchorOf><xsl:value-of select="."/></nif:anchorOf>
				<xsl:apply-templates select="@its-ta-confidence | @its-ta-class-ref | @its-ta-ident-ref | @its-ta-ident | @its-ta-source" mode="writeTa"/>
				<nif:referenceContext rdf:resource="{$referenceContext}"/>
			</rdf:Description>
		</xsl:if>
		<xsl:apply-templates mode="processStripped">
			<xsl:with-param name="offset">
				<xsl:value-of select="$offset-start"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="text()" mode="processStripped"/>
	<xsl:template mode="writeTa" match="@its-ta-class-ref"><itsrdf:taClassRef rdf:resource="{.}"/></xsl:template>
	<xsl:template mode="writeTa" match="@its-ta-ident-ref"><itsrdf:taIdentRef rdf:resource="{.}"/></xsl:template>
	<xsl:template mode="writeTa" match="@its-ta-ident"><itsrdf:taIdentRef rdf:resource="{.}"/></xsl:template>
	<xsl:template mode="writeTa" match="@its-ta-source"><itsrdf:taIdentRef rdf:resource="{.}"/></xsl:template>
	<xsl:template match="@its-ta-confidence" mode="writeTa"><itsrdf:taConfidence><xsl:value-of select="."/></itsrdf:taConfidence></xsl:template>
</xsl:stylesheet>