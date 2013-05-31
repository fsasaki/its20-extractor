<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:nif="http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#">
	<xsl:output indent="no" method="text"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="inputdoc" select="."/>
	<xsl:variable name="referenceContext" select="//rdf:Description[nif:sourceUrl]"/>
	<xsl:template match="/">
		<xsl:text>@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .
@prefix itsrdf: &lt;http://www.w3.org/2005/11/its/rdf#&gt; .
@prefix nif: &lt;http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#&gt; .&#xA;</xsl:text>
		<xsl:text>&#xA;&lt;</xsl:text>
		<xsl:value-of select="concat($referenceContext/@rdf:about,'&gt;')"/>
		<xsl:text>&#xA;&#x9;a&#x20;nif:Context&#x20;;</xsl:text>
		<xsl:text>&#xA;&#x9;a&#x20;nif:RFC5147String&#x20;;</xsl:text>
		<xsl:apply-templates select="//rdf:Description[@rdf:about=$referenceContext/@rdf:about]/*[not(self::nif:beginIndex or self::nif:endIndex or self::rdf:type[@rdf:resource='http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#RFC5147String'])]"/>
		<xsl:apply-templates select="//rdf:Description[@rdf:about=$referenceContext/@rdf:about][1]/*[self::nif:beginIndex or self::nif:endIndex]"/>
		<xsl:apply-templates select="//rdf:Description[@rdf:about=$referenceContext/@rdf:about]/nif:referenceContext[1]" mode="writeOverallReferenceContext"/>
		<xsl:text>&#xA;&#x9;nif:isString&#x20;"</xsl:text>
		<xsl:value-of select="$referenceContext/nif:isString"/>
		<xsl:text>"&#x20;.&#xA;</xsl:text>
		<xsl:for-each
			select="distinct-values(//rdf:Description[not(@rdf:about=$referenceContext/@rdf:about)]/@rdf:about)">
			<xsl:variable name="me" select="."/>
			<xsl:text>&#xA;&lt;</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>&gt;</xsl:text>
			<xsl:for-each
				select="$inputdoc//rdf:Description[@rdf:about=$me and not(@rdf:about=$referenceContext/@rdf:about)]">
				<xsl:apply-templates/>
			</xsl:for-each>
			<xsl:text>&#xA;&#x9;nif:referenceContext&#x20;&lt;</xsl:text>
			<xsl:value-of select="$referenceContext/@rdf:about"/>
			<xsl:text>&gt;.&#xA;</xsl:text>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="nif:referenceContext" mode="writeOverallReferenceContext">
		<xsl:text>&#xA;&#x9;nif:referenceContext</xsl:text>
		<xsl:text>&#x20;&lt;</xsl:text>
		<xsl:value-of select="@rdf:resource"/>
		<xsl:text>&gt;&#x20;;</xsl:text>
	</xsl:template>
	<xsl:template match="rdf:type | nif:anchorOf | nif:referenceContext | nif:sourceUrl | nif:isString | nif:convertedFrom" priority="+1"/>
	<xsl:template match="rdf:type[@rdf:resource='http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#RFC5147String']" priority="+2">
		<xsl:text>&#xA;&#x9;a&#x20;nif:RFC5147String&#x20;;</xsl:text>
	</xsl:template>
	<xsl:template match="nif:beginIndex | nif:endIndex">
		<xsl:text>&#xA;&#x9;</xsl:text>
		<xsl:value-of select="concat(name(),'&#x20;&quot;',.,'&quot;&#x20;;')"/>
	</xsl:template>
	<xsl:template match="itsrdf:hasLocQualityIssue">
		<xsl:for-each select="itsrdf:LocQualityIssue">
			<xsl:text>&#xA;&#x9;itsrdf:hasLocQualityIssue [</xsl:text>
			<xsl:text>&#xA;&#x9;&#x9;a itsrdf:LocQualityIssue ;</xsl:text>
			<xsl:apply-templates select="*"/>
			<xsl:text>&#xA;&#x9;];</xsl:text>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="*" priority="-1">
		<xsl:text>&#xA;&#x9;&#x9;</xsl:text>
		<xsl:value-of select="name(self::*)"/>
		<xsl:text>&#x20;"</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"&#x20;;</xsl:text>
	</xsl:template>
	<xsl:template match="*[@rdf:resource and not(name()='nif:referenceContext')]">
		<xsl:text>&#xA;&#x9;&#x9;</xsl:text>
		<xsl:value-of select="name(self::*)"/>
		<xsl:text>&#x20;&lt;</xsl:text>
		<xsl:value-of select="@rdf:resource"/>
		<xsl:text>&gt;&#x20;;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
