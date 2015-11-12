<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:its="http://www.w3.org/2005/11/its">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" exclude-result-prefixes="its"/>
	<xsl:key name="nodePath" match="node" use="@path"/>
	<xsl:param name="base-uri">http://example.com/exampledoc.xml</xsl:param>
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
		<rdf:RDF
			xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
			xmlns:oa="http://www.w3.org/ns/oa#"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			>
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
		<xsl:variable name="annotationNumber"><xsl:number level="any" count="*"/></xsl:variable>
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
				test="key('nodePath',$element-path)/output/@* | key('nodePath',$element-path)/output/* | key('nodePath',$element-path)/output[matches(.,'\S') and ancestor::nodeList[@datacat='idvalue']] and not($offset-start = $child-offset-start and $offset-end = $child-offset-end) and not($offset-start = $offset-end)">
				<!-- tbd: breaks with externalResource:  
				<output xmlns:db="docbook.org/ns/docbook">
					<externalResourceRefPointer fileref="movie.avi"/>
				</output> -->
				<!-- Produce only triples if the current element has *not* the same text content as the first child node, and if there is actual textual content.  -->
			<!-- 	<xsl:if
					test="not($offset-start = $child-offset-start and $offset-end = $child-offset-end) and not($offset-start = $offset-end)"> 
					deleted the below so that there is output for annotations of attributes
			-->
				<xsl:if
					test="not($offset-start = $child-offset-start and $offset-end = $child-offset-end)">
					
					<rdf:Description>
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="concat('http://example.com/myannotations/a',$annotationNumber)"/>
						</xsl:attribute>
						<!-- 					<xsl:comment>current start: <xsl:value-of select="$offset-start"/>
						current end: <xsl:value-of select="$offset-end"/>
						current path: <xsl:value-of select="$element-path"/>
						current child start: <xsl:value-of select="$child-offset-start"/>
						current child endt: <xsl:value-of select="$child-offset-end"/></xsl:comment> -->
						<oa:hasBody xmlns:oa="http://www.w3.org/ns/oa#" rdf:nodeID="{concat('b',$annotationNumber)}"/>
						<oa:hasTarget
							rdf:resource="{concat('http://example.com/mytargets/t',$annotationNumber)}" xmlns:oa="http://www.w3.org/ns/oa#"
						/>
						<rdf:type rdf:resource="http://www.w3.org/ns/oa#Annotation"/>
					</rdf:Description>
					<rdf:Description rdf:about="{concat('http://example.com/mytargets/t',$annotationNumber)}" xmlns:oa="http://www.w3.org/ns/oa#">
						<oa:hasSource rdf:resource="http://example.com/myfile.xml"/>
						<oa:hasSelector rdf:nodeID="{concat('s',$annotationNumber)}"/>
					</rdf:Description>
					<rdf:Description rdf:nodeID="{concat('s',$annotationNumber)}" xmlns:oa="http://www.w3.org/ns/oa#">
						<rdf:type rdf:resource="http://www.w3.org/ns/oa#FragmentSelector"/>
						<dcterms:conformsTo xmlns:dcterms="http://purl.org/dc/terms/" rdf:resource="http://www.w3.org/TR/xpath/"/>
						<rdf:value><xsl:value-of select="$element-path"/></rdf:value>
					</rdf:Description>
					<rdf:Description rdf:nodeID="{concat('b',$annotationNumber)}">
						<xsl:variable name="found">					
							<xsl:for-each
								select="key('nodePath',$element-path)/output/@* | key('nodePath',$element-path)/output/*[not(local-name()='locQualityIssue')] | key('nodePath',$element-path)/output[matches(.,'\S') and ancestor::nodeList[@datacat='idvalue']]">
								<xsl:call-template name="generateTriple"/>
							</xsl:for-each>
							<!-- 					<xsl:variable name="escapedElementPath"t
						select="replace(replace($element-path,'\[','%5B'),'\]','%5D')"/> -->
						</xsl:variable>
						<xsl:for-each select="$found/*">
							<xsl:variable name="currentName" select="name()"/>
							<xsl:if test="not(following-sibling::*[name()=$currentName])">
								<xsl:copy-of select="."/>
							</xsl:if>
						</xsl:for-each>
					</rdf:Description>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
		<xsl:apply-templates mode="processStripped"/>
	</xsl:template>
	<xsl:template name="generateTriple">
		<xsl:variable name="predicateName">
			<xsl:choose>
				<xsl:when test="local-name()='targetPointer'">itsrdf:targetPointer</xsl:when>
				<xsl:when test="ancestor::nodeList[@datacat='idvalue']">itsrdf:idvalue</xsl:when>
				<xsl:when test="contains(local-name(),'Pointer')">itsrdf:<xsl:value-of select="substring-before(local-name(),'Pointer')"/></xsl:when>
				<xsl:when test="namespace-uri()=''">itsrdf:<xsl:value-of select="name()"/>
				</xsl:when>
				<xsl:otherwise>itsrdf:<xsl:value-of select="local-name()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$predicateName}">
			<xsl:apply-templates mode="writeObjects" select="self::node()"/>
		</xsl:element>
		<xsl:if test="local-name() = 'localeFilterList' and not(parent::*/@*[local-name()='localeFilterType'])">
			<xsl:text>itsrdf:localeFilterType "included";</xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template mode="writeObjects" match="@*">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="@*[local-name()='taIdentRef' or local-name()='its-ta-ident-ref' or local-name()='taClassRef' or local-name()='its-ta-class-ref' or local-name()='locQualityIssueProfileRef']" mode="writeObjects">
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
	<xsl:template match="externalResourceRefPointer" mode="writeObjects"><xsl:value-of select="node()|@*"/></xsl:template>
	<xsl:template match="domainPointer" mode="writeObjects"><xsl:value-of select="node()|@*"/></xsl:template>
	<xsl:template match="langPointer" mode="writeObjects"><xsl:value-of select="node()|@*"/></xsl:template>
</xsl:stylesheet>
