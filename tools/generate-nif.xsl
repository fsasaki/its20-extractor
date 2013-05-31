<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:its="http://www.w3.org/2005/11/its" 
	xmlns:nif="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" exclude-result-prefixes="its"/>
	<xsl:key name="nodePath" match="node" use="@path"/>
	<xsl:param name="base-uri">http://example.com/exampledoc.html</xsl:param>
	<xsl:variable name="nif-ontology-ns"
		>"http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#</xsl:variable>
	<xsl:variable name="inputdoc-decorated"
		select="doc('../temp/nodelist-with-its-information.xml')"/>
	<xsl:include href="stripping.xsl"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="whiteSpaceStripped">
		<xsl:apply-templates select="/" mode="stripWS"/>
	</xsl:variable>
	<xsl:variable name="completeStringLength" select="string-length($whiteSpaceStripped)"/>
	<xsl:variable name="referenceContext"
		select="concat($base-uri,'#char=0,',$completeStringLength)"/>
	<xsl:template match="/">
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#">
			<rdf:Description rdf:about="{$referenceContext}">
				<nif:sourceUrl rdf:resource="{$base-uri}"/>
				<nif:beginIndex>0</nif:beginIndex>
				<nif:endIndex><xsl:value-of select="$completeStringLength"/></nif:endIndex>
				<nif:isString>
					<xsl:value-of select="$whiteSpaceStripped"/>
				</nif:isString>
				<rdf:type
					rdf:resource="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#Context"
				/>
			</rdf:Description>
			<xsl:apply-templates select="$whiteSpaceStripped" mode="processStripped"/>
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="text()" mode="processStripped"/>
	<xsl:template match="*|@*" mode="get-full-path">
		<xsl:apply-templates select="parent::*" mode="get-full-path"/>
		<xsl:text>/</xsl:text>
		<xsl:if test="count(. | ../@*) = count(../@*)">@</xsl:if>
		<xsl:value-of select="name()"/>
		<xsl:if test="self::* and parent::*">
			<xsl:text>[</xsl:text>
			<xsl:number/>
			<xsl:text>]</xsl:text>
		</xsl:if>
		<!-- <xsl:if test="not(child::*)">/text()[1]</xsl:if> -->
	</xsl:template>
	<xsl:template match="*" mode="processStripped">
		<xsl:variable name="element-path">
			<xsl:apply-templates select="." mode="get-full-path"/>
		</xsl:variable>
		<xsl:variable name="me" select="."/>
		<xsl:variable name="preceding">
			<xsl:value-of select="preceding::text()"/>
		</xsl:variable>
		<xsl:variable name="offset-start" select="string-length($preceding)"/>
		<xsl:variable name="offset-end" select="$offset-start + string-length(.)"/>
		<xsl:variable name="childPreceding">
			<xsl:value-of select="child::*[1]/preceding::text()"/>
		</xsl:variable>
		<xsl:variable name="child-offset-start" select="string-length($childPreceding)"/>
		<xsl:variable name="child-offset-end"
			select="$child-offset-start + string-length(child::*[1])"/>
		<xsl:for-each select="$inputdoc-decorated">
			<xsl:if
				test="key('nodePath',$element-path)/output/@* | key('nodePath',$element-path)/output/*">
				<!-- Produce only triples if the current element has *not* the same text content as the first child node  -->
				<xsl:if
					test="not($offset-start = $child-offset-start and $offset-end = $child-offset-end)">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
							<xsl:value-of
								select="concat($base-uri,'#char=',$offset-start,',',$offset-end)"/>
						</xsl:attribute>
						<!-- 					<xsl:comment>current start: <xsl:value-of select="$offset-start"/>
						current end: <xsl:value-of select="$offset-end"/>
						current path: <xsl:value-of select="$element-path"/>
						current child start: <xsl:value-of select="$child-offset-start"/>
						current child endt: <xsl:value-of select="$child-offset-end"/></xsl:comment> -->
						<nif:beginIndex><xsl:value-of select="$offset-start"/></nif:beginIndex>
						<nif:endIndex><xsl:value-of select="$offset-end"/></nif:endIndex>
						<rdf:type
							rdf:resource="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#RFC5147String"/>
						<nif:anchorOf>
							<xsl:value-of select="$me"/>
						</nif:anchorOf>
						<xsl:for-each
							select="key('nodePath',$element-path)/output/@* | key('nodePath',$element-path)/output/*[not(local-name()='locQualityIssue')]">
							<xsl:call-template name="generateTriple"/>
						</xsl:for-each>
						<nif:referenceContext rdf:resource="{$referenceContext}"/>
					</rdf:Description>
<!-- 					<xsl:variable name="escapedElementPath"
						select="replace(replace($element-path,'\[','%5B'),'\]','%5D')"/> -->
					<rdf:Description
						rdf:about="{concat($base-uri,'#char=',$offset-start,',',$offset-end)}">
						<nif:convertedFrom
							rdf:resource="{concat($base-uri,'#xpath(',$element-path,')')}"
						/>
					</rdf:Description>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
		<xsl:apply-templates mode="processStripped"/>
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
			<xsl:apply-templates mode="writeObjects" select="self::node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template mode="writeObjects" match="@*">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="@*[local-name()='taIdentRef' or local-name()='locQualityIssueProfileRef']" mode="writeObjects">
		<xsl:attribute name="rdf:resource">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template mode="writeObjects" match="@hasLocQualityIssue">
		<xsl:for-each select="parent::*/its:locQualityIssue">
		<itsrdf:LocQualityIssue>
			<xsl:for-each select="@*">
				<xsl:call-template name="generateTriple"/>
			</xsl:for-each>
		</itsrdf:LocQualityIssue>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
