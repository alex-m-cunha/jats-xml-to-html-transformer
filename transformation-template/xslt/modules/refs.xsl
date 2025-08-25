<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink">
  
  <xsl:template match="ref-list">
    <section id="references" aria-labelledby="ref-h">
      <h2 id="ref-h">References</h2>
      <ol class="references">
        <xsl:apply-templates select="ref"/>
      </ol>
    </section>
  </xsl:template>
  
  <xsl:template match="ref">
    <li id="{@id}">
      <!-- Text without inline link clutter -->
      <span class="ref-text">
        <xsl:apply-templates
          select="(mixed-citation|element-citation)/node()[not(self::uri or self::ext-link or self::pub-id)]"/>
      </span>
      <xsl:text> </xsl:text>
      <xsl:call-template name="ref-link-badges"/>
    </li>
  </xsl:template>
  
  <!-- Build badges with XSLT 1.0-compatible branching -->
  <xsl:template name="ref-link-badges">
    <xsl:variable name="root" select="(mixed-citation|element-citation)[1]"/>
    <xsl:variable name="links" select="$root//uri | $root//ext-link"/>
    
    <!-- DOI -->
    <xsl:variable name="doi-id" select="normalize-space($root/pub-id[@pub-id-type='doi'][1])"/>
    <xsl:variable name="doi-url">
      <xsl:choose>
        <xsl:when test="string-length($doi-id)&gt;0">
          <xsl:value-of select="concat('https://doi.org/',$doi-id)"/>
        </xsl:when>
        <xsl:when test="$links[contains(@xlink:href,'doi.org')]">
          <xsl:value-of select="$links[contains(@xlink:href,'doi.org')][1]/@xlink:href"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <!-- PubMed -->
    <xsl:variable name="pmid-id" select="normalize-space($root/pub-id[@pub-id-type='pmid'][1])"/>
    <xsl:variable name="pmid-url">
      <xsl:choose>
        <xsl:when test="string-length($pmid-id)&gt;0">
          <xsl:value-of select="concat('https://pubmed.ncbi.nlm.nih.gov/',$pmid-id,'/')"/>
        </xsl:when>
        <xsl:when test="$links[contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov') or contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed')]">
          <xsl:value-of select="$links[contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov') or contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed')][1]/@xlink:href"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <!-- PMC -->
    <xsl:variable name="pmcid-id" select="normalize-space($root/pub-id[@pub-id-type='pmcid'][1])"/>
    <xsl:variable name="pmcid-fixed">
      <xsl:choose>
        <xsl:when test="starts-with($pmcid-id,'PMC')"><xsl:value-of select="$pmcid-id"/></xsl:when>
        <xsl:when test="string-length($pmcid-id)&gt;0">PMC<xsl:value-of select="$pmcid-id"/></xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pmc-url">
      <xsl:choose>
        <xsl:when test="string-length($pmcid-fixed)&gt;0">
          <xsl:value-of select="concat('https://www.ncbi.nlm.nih.gov/pmc/articles/',$pmcid-fixed,'/')"/>
        </xsl:when>
        <xsl:when test="$links[contains(@xlink:href,'ncbi.nlm.nih.gov/pmc')]">
          <xsl:value-of select="$links[contains(@xlink:href,'ncbi.nlm.nih.gov/pmc')][1]/@xlink:href"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <!-- ResearchGate & Scholar -->
    <xsl:variable name="rg-url" select="$links[contains(@xlink:href,'researchgate.net')][1]/@xlink:href"/>
    <xsl:variable name="scholar-url" select="$links[contains(@xlink:href,'scholar.google')][1]/@xlink:href"/>
    
    <!-- Generic URLs -->
    <xsl:variable name="generic-urls"
      select="$links[not(contains(@xlink:href,'doi.org')
      or contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov')
      or contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed')
      or contains(@xlink:href,'ncbi.nlm.nih.gov/pmc')
      or contains(@xlink:href,'researchgate.net')
      or contains(@xlink:href,'scholar.google'))]/@xlink:href"/>
    
    <!-- Output badges inline with spacing -->
    <xsl:if test="string-length(normalize-space($doi-url)) or string-length(normalize-space($pmid-url)) or string-length(normalize-space($pmc-url)) or string-length(normalize-space($rg-url)) or string-length(normalize-space($scholar-url)) or count($generic-urls)&gt;0">
      <span class="ref-links">
        <xsl:if test="string-length(normalize-space($doi-url))">
          <a href="{$doi-url}" target="_blank" rel="noopener">DOI</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($pmid-url))">
          <a href="{$pmid-url}" target="_blank" rel="noopener">PubMed</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($pmc-url))">
          <a href="{$pmc-url}" target="_blank" rel="noopener">PMC</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($rg-url))">
          <a href="{$rg-url}" target="_blank" rel="noopener">ResearchGate</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($scholar-url))">
          <a href="{$scholar-url}" target="_blank" rel="noopener">Google Scholar</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:for-each select="$generic-urls">
          <a href="{.}" target="_blank" rel="noopener"><xsl:value-of select="."/></a>
          <xsl:if test="position()!=last()"><xsl:text>   </xsl:text></xsl:if>
        </xsl:for-each>
      </span>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>