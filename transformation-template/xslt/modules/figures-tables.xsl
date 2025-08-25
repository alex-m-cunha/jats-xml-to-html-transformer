<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">
  
  <xsl:template match="/article" mode="figures-tables">
    
    <!-- Collect everything once -->
    <xsl:variable name="all-figures" select=".//fig"/>
    
    <!-- ===== Figures ===== -->
    <xsl:if test="count($all-figures) &gt; 0">
      <section id="all-figures" class="figures-collection" aria-labelledby="all-figures-h">
        <h2 id="all-figures-h">Figures</h2>
        <xsl:for-each select="$all-figures">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </section>
    </xsl:if>
  </xsl:template>
 </xsl:stylesheet>