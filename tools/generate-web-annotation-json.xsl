<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#"
	xmlns:oa="http://www.w3.org/ns/oa#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:its="http://www.w3.org/2005/11/its">
	<xsl:output indent="yes" method="text" omit-xml-declaration="yes"/>
	<xsl:key name="body" match="rdf:Description" use="@rdf:nodeID"/>
	<xsl:key name="target" match="rdf:Description" use="@rdf:about"/>
	<xsl:key name="targetselector" match="rdf:Description" use="@rdf:nodeID"/>
	<xsl:template match="/">
		{
		"@context": [
		"http://www.w3.org/ns/anno.jsonld",
		{"itsrdf": "http://www.w3.org/2005/11/its/rdf#"}
		],
		"Container" : [
		<xsl:for-each select="//*[@rdf:about[contains(.,'annotations')]]">
			{
			<xsl:variable name="target" select="key('target',oa:hasTarget/@rdf:resource)"/>
			"@id" : "<xsl:value-of select="@rdf:about"/>",
			"@type" : "Annotation",
			"target" :  {
		"source" : "<xsl:value-of select="$target/oa:hasSource/@rdf:resource"/>",
			"selector" : {
			"@type" : "FragmentSelector",
			"conformsTo" : "http://www.w3.org/TR/xpath/",
			"value" : 
			"<xsl:value-of select="key('targetselector',$target/oa:hasSelector/@rdf:nodeID)/rdf:value"/>" }},
			"body" : {
			<xsl:for-each select="key('body',oa:hasBody/@rdf:nodeID)/*">
				"<xsl:value-of select="name()"></xsl:value-of>" : "<xsl:value-of select="normalize-space(.)"/>"
				<xsl:if test="not(position()=last())">,</xsl:if>
			</xsl:for-each>
			}
			}
			<xsl:if test="not(position()=last())">,</xsl:if>
		</xsl:for-each>		
		]
		}
	</xsl:template>
</xsl:stylesheet>
<!--    <rdf:Description rdf:about="http://example.com/myannotations/a1">
      <oa:hasBody rdf:nodeID="b1"/>
      <oa:hasTarget rdf:resource="http://example.com/mytargets/t1"/>
      <rdf:type rdf:resource="http://www.w3.org/ns/oa#Annotation"/>
   </rdf:Description>
   <rdf:Description rdf:about="http://example.com/mytargets/t1">
      <oa:hasSource rdf:resource="http://example.com/myfile.xml"/>
      <oa:hasSelector rdf:nodeID="s1"/>
   </rdf:Description>
   <rdf:Description rdf:nodeID="s1">
      <rdf:type rdf:resource="http://www.w3.org/ns/oa#FragmentSelector"/>
      <dcterms:conformsTo xmlns:dcterms="http://purl.org/dc/terms/"
                          rdf:resource="http://www.w3.org/TR/xpath/"/>
      <rdf:value>/itsProcessingInput</rdf:value>
   </rdf:Description>
   <rdf:Description rdf:nodeID="b1">
      <itsrdf:translate>yes</itsrdf:translate>
      <itsrdf:dir>ltr</itsrdf:dir>
      <itsrdf:withinText>no</itsrdf:withinText>
      <itsrdf:term>no</itsrdf:term>
      <itsrdf:localeFilterList>*</itsrdf:localeFilterList>
      <itsrdf:localeFilterType>included</itsrdf:localeFilterType>
   </rdf:Description> -->