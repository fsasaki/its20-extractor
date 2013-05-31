<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:its="http://www.w3.org/2005/11/its" xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:datc="http://example.com/datacats" version="2.0" exclude-result-prefixes="datc its"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:param name="base-uri">http://example.com/exampledoc.html#</xsl:param>
	<xsl:template match="/">
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#">
			<xsl:for-each
				select="distinct-values(for $paths in //node[//output/* | //output/@*]/@path return $paths)">
				<xsl:variable name="currentPath" select="."/>
				<rdf:Description>
					<xsl:variable name="subject">
						<xsl:value-of select="$base-uri"/>
						<xsl:text>xpath(</xsl:text>
						<xsl:value-of select="$currentPath"/>
						<xsl:text>)</xsl:text>
					</xsl:variable>
					<xsl:attribute name="rdf:about" select="$subject"/>
					<xsl:for-each
						select="doc('../temp/nodelist-with-its-information.xml')//node[@path=$currentPath]/output/* | doc('../temp/nodelist-with-its-information.xml')//node[@path=$currentPath]/output/@*">
						<xsl:call-template name="generateTriple"/>
					</xsl:for-each>
				</rdf:Description>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>
	<xsl:template name="generateTriple">
		<xsl:variable name="predicateName">
			<xsl:choose>
				<xsl:when test="namespace-uri()=''">itsrdf:<xsl:value-of select="name()"/>
				</xsl:when>
				<xsl:otherwise>itsrdf:<xsl:value-of select="local-name()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$predicateName}">
			<xsl:choose>
				<!-- Special handling for translate -->
				<xsl:when test="self::attribute() and local-name()='translate'">
					<xsl:attribute name="rdf:datatype"
						>http://www.w3.org/TR/its-2.0/its.xsd#yesOrNo</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:when>
				<!-- Special handling for locNoteType -->
				<xsl:when test="self::attribute() and local-name()='locNoteType'">
					<xsl:attribute name="rdf:datatype"
						>http://www.w3.org/TR/its-2.0/its.xsd#locNoteType</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:when>
				<!-- Special handling for term -->
				<xsl:when test="self::attribute() and local-name()='term'">
					<xsl:attribute name="rdf:datatype"
						>http://www.w3.org/TR/its-2.0/its.xsd#term</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:when>
				<!-- Special handling for directionality -->
				<xsl:when test="self::attribute() and local-name()='dir'">
					<xsl:attribute name="rdf:datatype"
						>http://www.w3.org/TR/its-2.0/its.xsd#dir</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="self::attribute()">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="rdf:parseType">Literal</xsl:attribute>
					<xsl:copy-of select="self::*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
