<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:h="http://www.w3.org/1999/xhtml" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:nif="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#"
	exclude-result-prefixes="h">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:param name="base-uri">http://example.com/exampledoc.html#</xsl:param>
	<xsl:param name="dbpediaPrefix">http://dbpedia.org/resource/</xsl:param>
	<xsl:variable name="wsStripped">
		<xsl:apply-templates mode="stripWS"/>
	</xsl:variable>
  <xsl:template match="*|@*" mode="get-full-path">
    <xsl:apply-templates select="parent::*" mode="get-full-path"/>
    <xsl:text>/</xsl:text>
    <xsl:if test="count(. | ../@*) = count(../@*)">@</xsl:if>
    <xsl:value-of select="name()"/>
    <xsl:if test="self::* and parent::*"><xsl:text>%5B</xsl:text><xsl:number/><xsl:text>%5D</xsl:text></xsl:if>
    <xsl:if test="not(child::*)">/text()%5B1%5D</xsl:if>
  </xsl:template>
	<xsl:template match="node()|@*" mode="stripWS">
		<xsl:copy>
			<xsl:apply-templates mode="stripWS" select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template mode="stripWS" match="text()[not(matches(.,'\S'))]"/>
	<xsl:template mode="stripWS" match="text()[matches(.,'\S')]">
		<xsl:value-of select="replace(.,'\s+',' ')"/>
	</xsl:template>
	<xsl:template match="/">
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#">
			<nif:Context rdf:about="{concat($base-uri,'char=0,',string-length($wsStripped/*))}">
				<rdf:type rdf:resource="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#RFC5147String"/>
				<nif:isString><xsl:value-of select="$wsStripped/*"/></nif:isString>
			</nif:Context>
			<xsl:apply-templates select="$wsStripped/*"/>
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="text() | comment() | processing-instruction()"/>
	<xsl:template match="h:p[h:a[starts-with(@href,'/wiki/') and not(contains(@href,'wiki/Template:'))]]">
		<xsl:variable name="preceding">
			<xsl:value-of select="preceding::text()"/>
		</xsl:variable>
		<xsl:variable name="offset-start" select="string-length($preceding)"/>
		<xsl:variable name="offset-end" select="$offset-start + string-length(.)"/>
		<nif:Paragraph rdf:about="{concat($base-uri,'char=',$offset-start,',',$offset-end)}">
			<rdf:type
				rdf:resource="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#RFC5147String"/>
<!-- 			<nif:beginIndex><xsl:value-of select="$offset-start"/></nif:beginIndex>
			<nif:endIndex><xsl:value-of select="$offset-end"/></nif:endIndex>
			<nif:isString>
				<xsl:value-of select="."/>
			</nif:isString> -->
		</nif:Paragraph>
		<xsl:apply-templates mode="writeTaIdentRef">
			<xsl:with-param name="currentOffset" select="$offset-start"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template mode="writeTaIdentRef" match="node()"/>
	<xsl:template match="h:a[starts-with(@href,'/wiki/') and not(contains(@href,'wiki/Template:'))]" mode="writeTaIdentRef">
		<xsl:param name="currentOffset"/>
		<xsl:variable name="preceding-sibling">
			<xsl:value-of select="preceding-sibling::text()"/>
		</xsl:variable>
		<xsl:variable name="offset-start" select="string-length($preceding-sibling) + $currentOffset"/>
		<xsl:variable name="offset-end" select="$offset-start + string-length(.)"/>
	  <xsl:variable name="element-path"><xsl:apply-templates select="." mode="get-full-path"/></xsl:variable>
	  <rdf:Description rdf:about="{concat($base-uri,'#xpath(',$element-path,')')}">
	    <nif:convertedFrom rdf:resource="{concat($base-uri,'#char=',$offset-start,',',$offset-end)}"/>
	  </rdf:Description>
		<nif:RFC5147String rdf:about="{concat($base-uri,'char=',$offset-start,',',$offset-end)}">
			<nif:beginIndex><xsl:value-of select="$offset-start"/></nif:beginIndex>
			<nif:endIndex><xsl:value-of select="$offset-end"/></nif:endIndex>
			<itsrdf:taIdentRef rdf:resource="{concat($dbpediaPrefix,substring-after(@href,'wiki/'))}"/>
		</nif:RFC5147String>
	</xsl:template>
</xsl:stylesheet>