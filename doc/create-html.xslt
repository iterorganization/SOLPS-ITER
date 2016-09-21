<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
  <h1>SOLPS-ITER B2.5 input parameters</h1>
  <table border="1">
    <tr bgcolor="#9acd32">
      <th>Name</th>
      <th>Default</th>
      <th>Input File</th>
      <th>Description</th>
    </tr>
    <xsl:for-each select="solps/module/param">
    <tr>
      <td><xsl:value-of select="name"/></td>
      <td><xsl:value-of select="default"/></td>
      <td><xsl:value-of select="../@name"/></td>
      <td><xsl:value-of select="description"/></td>
    </tr>
    </xsl:for-each>
  </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet> 
