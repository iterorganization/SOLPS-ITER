<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" 
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0"
	xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
	xmlns:exsl="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions"
	xmlns:dyn="http://exslt.org/dynamic"
	xmlns:set="http://exslt.org/sets"
	xmlns:my="http://localhost.localdomain/localns"
	extension-element-prefixes="func dyn set"
	exclude-result-prefixes="my">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<xsl:template match="/">
   \begin{description}
   <xsl:for-each select="solps/code/module/param">
      <xsl:text>\item[</xsl:text><xsl:value-of select="name"/><xsl:text>] </xsl:text>
      <xsl:text>\message{</xsl:text><xsl:value-of select="name"/> at page \thepage}
      <xsl:value-of select="description"/>
   </xsl:for-each>
   \end{description}
</xsl:template>

</xsl:stylesheet>
