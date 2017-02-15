<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:exslt="http://exslt.org/common">

<xsl:output method="text" />


<xsl:template match="solps">
<xsl:for-each select="module">
<xsl:value-of select="@name"/>_tooltips = {
         <xsl:call-template name="params"/>
}
</xsl:for-each>  
</xsl:template>
   
<xsl:template name="params">
   <xsl:param name="input_file"/>
   <!--xsl:for-each select="concat('/solps/',$string_name,'/paramgroup')"-->
   <xsl:for-each select="paramgroup/param">
      '<xsl:value-of select="name"/>' : ('<xsl:value-of select="../category"/>', '<xsl:value-of select="type"/>', """<xsl:value-of select="../description"/>""", '<xsl:value-of select="default"/>'),
   </xsl:for-each>
   <xsl:for-each select="param">
      '<xsl:value-of select="name"/>' : ('<xsl:value-of select="category"/>', '<xsl:value-of select="type"/>', """<xsl:value-of select="description"/>""", '<xsl:value-of select="default"/>'),
   </xsl:for-each>
</xsl:template>
</xsl:stylesheet>