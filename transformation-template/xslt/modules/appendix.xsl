<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">
  
  <!-- Entry point: Figures under Appendix -->
  <xsl:template match="/article/back/sec[normalize-space(title) = 'Appendix']">
    
    <!-- all figures that live under a sec whose <title> is exactly 'Appendix' -->
    <xsl:variable name="appendix-figs" select="fig"/>
    
    <xsl:if test="$appendix-figs">
      <section id="appendix" class="sec-label" aria-labelledby="appendix-h">
        <h2 id="appendix-h">
          <xsl:value-of select="/article/back/sec/title"/>
        </h2>
        <xsl:apply-templates select="$appendix-figs"/>
      </section>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>