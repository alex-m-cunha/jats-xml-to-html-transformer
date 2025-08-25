<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">
  
  <!-- =========================
       REFERENCES (main section)
       ========================= -->
  <xsl:template match="ref-list" mode="list">
    <section id="references" aria-labelledby="ref-h">
      <h2 id="ref-h">References</h2>
      <ol class="references">
        <xsl:apply-templates select="ref"/>
      </ol>
    </section>
  </xsl:template>
  
  <!-- Each reference item: accessible, stable id, clean text + badges -->
  <xsl:template match="ref">
    <xsl:variable name="rid" select="@id"/>
    <li id="{$rid}" class="reference" role="doc-biblioentry">
      <span class="ref-text">
        <!-- Avoid re-inlining uri/pub-id to keep badges separate -->
        <xsl:apply-templates
          select="(mixed-citation|element-citation)/node()[not(self::uri or self::ext-link or self::pub-id)]"/>
      </span>
      <xsl:text> </xsl:text>
      <xsl:call-template name="ref-link-badges-list"/>
    </li>
  </xsl:template>
  
  <!-- Link badges for the list view (opens new tab, 3 spaces as separators) -->
  <xsl:template name="ref-link-badges-list">
    <xsl:variable name="root" select="(mixed-citation|element-citation)[1]"/>
    <xsl:variable name="links" select="$root//uri | $root//ext-link"/>
    
    <!-- DOI -->
    <xsl:variable name="doi-id" select="normalize-space($root/pub-id[@pub-id-type='doi'][1])"/>
    <xsl:variable name="doi-url">
      <xsl:choose>
        <xsl:when test="string-length($doi-id)&gt;0">https://doi.org/<xsl:value-of select="$doi-id"/></xsl:when>
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
        <xsl:when test="string-length($pmid-id)&gt;0">https://pubmed.ncbi.nlm.nih.gov/<xsl:value-of select="$pmid-id"/>/</xsl:when>
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
        <xsl:when test="string-length($pmcid-fixed)&gt;0">https://www.ncbi.nlm.nih.gov/pmc/articles/<xsl:value-of select="$pmcid-fixed"/>/</xsl:when>
        <xsl:when test="$links[contains(@xlink:href,'ncbi.nlm.nih.gov/pmc')]">
          <xsl:value-of select="$links[contains(@xlink:href,'ncbi.nlm.nih.gov/pmc')][1]/@xlink:href"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <!-- ResearchGate / Google Scholar (direct URLs only) -->
    <xsl:variable name="rg-url" select="$links[contains(@xlink:href,'researchgate.net')][1]/@xlink:href"/>
    <xsl:variable name="scholar-url" select="$links[contains(@xlink:href,'scholar.google')][1]/@xlink:href"/>
    
    <!-- Generic URLs (show full URL) -->
    <xsl:variable name="generic-urls"
      select="$links[not(contains(@xlink:href,'doi.org') or
      contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov') or contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed') or
      contains(@xlink:href,'ncbi.nlm.nih.gov/pmc') or
      contains(@xlink:href,'researchgate.net') or
      contains(@xlink:href,'scholar.google'))]/@xlink:href"/>
    
    <xsl:variable name="has-any"
      select="string-length(normalize-space($doi-url))&gt;0 or
      string-length(normalize-space($pmid-url))&gt;0 or
      string-length(normalize-space($pmc-url))&gt;0 or
      string-length(normalize-space($rg-url))&gt;0 or
      string-length(normalize-space($scholar-url))&gt;0 or
      count($generic-urls)&gt;0"/>
    
    <xsl:if test="$has-any">
      <span class="ref-links">
        <xsl:if test="string-length(normalize-space($doi-url))&gt;0">
          <a href="{$doi-url}" target="_blank" rel="noopener">DOI</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($pmid-url))&gt;0">
          <a href="{$pmid-url}" target="_blank" rel="noopener">PubMed</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($pmc-url))&gt;0">
          <a href="{$pmc-url}" target="_blank" rel="noopener">PMC</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($rg-url))&gt;0">
          <a href="{$rg-url}" target="_blank" rel="noopener">ResearchGate</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($scholar-url))&gt;0">
          <a href="{$scholar-url}" target="_blank" rel="noopener">Google Scholar</a><xsl:text>   </xsl:text>
        </xsl:if>
        <xsl:for-each select="$generic-urls">
          <a href="{.}" target="_blank" rel="noopener"><xsl:value-of select="."/></a>
          <xsl:if test="position()!=last()"><xsl:text>   </xsl:text></xsl:if>
        </xsl:for-each>
      </span>
    </xsl:if>
  </xsl:template>
  
  <!-- =======================
       FOOTNOTES (main section)
       ======================= -->
  <xsl:template match="fn-group" mode="list">
    <section id="footnotes" aria-labelledby="fn-h">
      <h2 id="fn-h">Footnotes</h2>
      <ol class="footnotes">
        <xsl:for-each select="fn">
          <li id="{@id}" class="footnote" role="doc-footnote">
            <xsl:apply-templates/>
          </li>
        </xsl:for-each>
      </ol>
    </section>
  </xsl:template>
  
  <!-- ===========================
       HIDDEN POPOVER CONTENT (refs)
       =========================== -->
  <xsl:template match="ref-list" mode="popovers">
    <div class="popovers popovers-refs" aria-hidden="true">
      <xsl:for-each select="ref">
        <xsl:variable name="rid" select="@id"/>
        <xsl:variable name="num" select="count(preceding-sibling::ref) + 1"/>
        <xsl:variable name="popId" select="concat('ref-pop-',$rid)"/>
        <div id="{concat('ref-pop-',$rid)}"
          class="popover ref-popover"
          role="dialog"
          aria-modal="false"
          aria-labelledby="{concat('ref-pop-',$rid,'-h')}"
          aria-describedby="{concat('ref-pop-',$rid,'-b')}"
          tabindex="-1"
          hidden="hidden">
          <span class="popover-header">
            <strong id="{concat('ref-pop-',$rid,'-h')}">Reference</strong>
            <button type="button" class="popover-close" aria-label="Close">×</button>
          </span>
          <div id="{concat('ref-pop-',$rid,'-b')}" class="popover-body">
            <div class="ref-text">
              <xsl:apply-templates
                select="(mixed-citation|element-citation)/node()[not(self::uri or self::ext-link or self::pub-id)]"/>
            </div>
            <xsl:call-template name="ref-link-badges-popover"/>
            <p class="visually-hidden">Press Escape to close this dialog.</p>
          </div>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <!-- Simpler badges for popover (identical behaviour as list; opens new tab) -->
  <xsl:template name="ref-link-badges-popover">
    <!-- reuse same logic as list version, keeping it separate for styling -->
    <xsl:call-template name="ref-link-badges-list"/>
  </xsl:template>
  
  <!-- ============ FOOTNOTE POPOVERS (hidden) ============ -->
  <!-- Emits a single hidden wrapper with one dialog per <fn> -->
  <xsl:template match="fn-group" mode="popovers">
    <div class="popovers popovers-fn" hidden="hidden" aria-hidden="true" aria-expanded="false">
      <xsl:for-each select="fn">
        <xsl:variable name="rid"     select="@id"/>
        <xsl:variable name="num"     select="count(preceding-sibling::fn) + 1"/>
        <xsl:variable name="popId"   select="concat('fn-pop-',$rid)"/>
        <xsl:variable name="popHead" select="concat($popId,'-h')"/>
        <xsl:variable name="popBody" select="concat($popId,'-b')"/>
        
        <div id="{$popId}" class="popover fn-popover"
          role="dialog" aria-modal="false"
          aria-labelledby="{$popHead}" aria-describedby="{$popBody}"
          hidden="hidden" aria-hidden="true" tabindex="-1">
          <span class="popover-header">
            <strong id="{$popHead}">Footnote <xsl:value-of select="$num"/></strong>
            <button type="button" class="popover-close" aria-label="Close footnote {$num}">×</button>
          </span>
          <div id="{$popBody}" class="popover-body">
            <xsl:apply-templates select="p"/>
          </div>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
  
</xsl:stylesheet>