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
      <xsl:call-template name="ref-link-badges"/>
    </li>
  </xsl:template>
  
  <!-- Link badges for the list view (opens new tab, 3 spaces as separators) -->
  <xsl:template name="ref-link-badges">
    <xsl:variable name="root"  select="(mixed-citation|element-citation)[1]"/>
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
    
    <!-- ResearchGate / Scholar -->
    <xsl:variable name="rg-url"      select="$links[contains(@xlink:href,'researchgate.net')][1]/@xlink:href"/>
    <xsl:variable name="scholar-url" select="$links[contains(@xlink:href,'scholar.google')][1]/@xlink:href"/>
    
    <!-- Generic full URLs -->
    <xsl:variable name="generic-urls"
      select="$links[not(contains(@xlink:href,'doi.org') or
      contains(@xlink:href,'pubmed.ncbi.nlm.nih.gov') or contains(@xlink:href,'ncbi.nlm.nih.gov/pubmed') or
      contains(@xlink:href,'ncbi.nlm.nih.gov/pmc') or
      contains(@xlink:href,'researchgate.net') or
      contains(@xlink:href,'scholar.google'))]/@xlink:href"/>
    
    <!-- Emit links inline, separated by 3 spaces -->
    <xsl:if test="normalize-space($doi-url)!=''">
      <a href="{$doi-url}" target="_blank" rel="noopener">DOI</a><xsl:text>   </xsl:text>
    </xsl:if>
    <xsl:if test="normalize-space($pmid-url)!=''">
      <a href="{$pmid-url}" target="_blank" rel="noopener">PubMed</a><xsl:text>   </xsl:text>
    </xsl:if>
    <xsl:if test="normalize-space($pmc-url)!=''">
      <a href="{$pmc-url}" target="_blank" rel="noopener">PMC</a><xsl:text>   </xsl:text>
    </xsl:if>
    <xsl:if test="normalize-space($rg-url)!=''">
      <a href="{$rg-url}" target="_blank" rel="noopener">ResearchGate</a><xsl:text>   </xsl:text>
    </xsl:if>
    <xsl:if test="normalize-space($scholar-url)!=''">
      <a href="{$scholar-url}" target="_blank" rel="noopener">Google Scholar</a><xsl:text>   </xsl:text>
    </xsl:if>
    <xsl:for-each select="$generic-urls">
      <a href="{.}" target="_blank" rel="noopener"><xsl:value-of select="."/></a>
      <xsl:if test="position()!=last()"><xsl:text>   </xsl:text></xsl:if>
    </xsl:for-each>
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
            <button type="button" class="popover-close" aria-label="Close">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 4L4 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M4 4L12 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </span>
          <div id="{concat('ref-pop-',$rid,'-b')}" class="popover-body">
            <div class="ref-text">
              <xsl:apply-templates
                select="(mixed-citation|element-citation)/node()[not(self::uri or self::ext-link or self::pub-id)]"/>
            </div>
            <xsl:call-template name="ref-link-badges"/>
            <p class="visually-hidden">Press Escape to close this dialog.</p>
          </div>
        </div>
      </xsl:for-each>
    </div>
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
            <button type="button" class="popover-close" aria-label="Close footnote {$num}">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 4L4 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M4 4L12 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </span>
          <div id="{$popBody}" class="popover-body">
            <xsl:apply-templates select="p"/>
          </div>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <!-- Keys you already use elsewhere (make sure these exist once globally) -->
  <!--
<xsl:key name="correspById" match="/article/front/article-meta/author-notes/corresp" use="@id"/>
<xsl:key name="affById"     match="/article/front/article-meta/aff"                  use="@id"/>
-->
  
  <!-- Entry point: render a hidden wrapper containing all author popovers -->
  <xsl:template match="/article" mode="author-popovers">
    <div class="popovers popovers-authors" hidden="hidden" aria-hidden="true">
      <xsl:for-each select="front/article-meta/contrib-group/contrib[@contrib-type='author']">
        <xsl:variable name="aid"     select="generate-id()"/>
        <xsl:variable name="panelId" select="concat('author-pop-', $aid)"/>
        <xsl:variable name="labelId" select="concat('author-label-', $aid)"/>
        
        <!-- ORCID resolution (copy of masthead logic, kept in sync) -->
        <xsl:variable name="orcid-id" select="normalize-space(contrib-id[@contrib-id-type='orcid'][1])"/>
        <xsl:variable name="orcid-url">
          <xsl:choose>
            <xsl:when test="string-length($orcid-id)&gt;0">
              <xsl:choose>
                <xsl:when test="contains($orcid-id,'http')"><xsl:value-of select="$orcid-id"/></xsl:when>
                <xsl:otherwise>https://orcid.org/<xsl:value-of select="$orcid-id"/></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="(.//ext-link | .//uri)[contains(@xlink:href,'orcid.org')]">
              <xsl:value-of select="((.//ext-link | .//uri)[contains(@xlink:href,'orcid.org')])[1]/@xlink:href"/>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:variable>
        
        <!-- presence flags (same as masthead) -->
        <xsl:variable name="has-corresp" select="boolean(xref[@ref-type='corresp']) or boolean(../../author-notes/corresp)"/>
        <xsl:variable name="has-orcid"   select="string-length(normalize-space($orcid-url)) &gt; 0"/>
        <xsl:variable name="has-aff"     select="boolean(xref[@ref-type='aff'])"/>
        <xsl:variable name="has-comp"    select="boolean(notes) or boolean(../../author-notes//fn[@fn-type='conflict'])"/>
        
        <!-- The popover itself (same markup you had before) -->
        <div id="{$panelId}"
          class="popover author-popover"
          role="dialog"
          aria-modal="false"
          aria-labelledby="{$labelId}"
          hidden="hidden"
          tabindex="-1">
          
          <div class="popover-header">
            <strong>
              <xsl:value-of select="normalize-space(name/given-names)"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-space(name/surname)"/>
            </strong>
            <button type="button" class="popover-close" aria-label="Close">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 4L4 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M4 4L12 12" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
          </div>
          
          <!-- Flag this author as corresponding only if they have an explicit xref → corresp -->
          <xsl:variable name="is-corresp" select="count(xref[@ref-type='corresp']/@rid) &gt; 0"/>
          
          <!-- Corresponding (only for this corresponding author) -->
          <xsl:if test="$is-corresp">
            <div class="popover-section">
              <div class="section-title">Corresponding Author</div>
              
              <!-- Resolve via xref rid(s) → author-notes/corresp -->
              <xsl:for-each select="xref[@ref-type='corresp']/@rid">
                <xsl:variable name="c" select="key('correspById', .)[1]"/>
                <p>
                  <xsl:choose>
                    <xsl:when test="$c">
                      <xsl:apply-templates select="$c/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="u-missing">[Correspondence not found: <xsl:value-of select="."/>]</span>
                    </xsl:otherwise>
                  </xsl:choose>
                </p>
              </xsl:for-each>
            </div>
          </xsl:if>
          
          <!-- ORCID -->
          <div class="popover-section">
            <div class="section-title">ORCID</div>
            <xsl:choose>
              <xsl:when test="$has-orcid">
                <p>
                  <a href="{$orcid-url}" rel="noopener" target="_blank">
                    <img src="{$assets-path}img/orcid-icon.svg" alt="" width="16" height="16"/>
                    <xsl:text> </xsl:text>
                    <span class="orcid-id"><xsl:value-of select="substring-after($orcid-url,'orcid.org/')"/></span>
                  </a>
                </p>
              </xsl:when>
              <xsl:otherwise><p>No ORCID provided.</p></xsl:otherwise>
            </xsl:choose>
          </div>
          
          <!-- Affiliations -->
          <div class="popover-section">
            <div class="section-title">Affiliations</div>
            <xsl:choose>
              <xsl:when test="$has-aff">
                <ul class="aff-list">
                  <xsl:for-each select="xref[@ref-type='aff']/@rid">
                    <li>
                      <xsl:variable name="aff" select="key('affById', .)[1]"/>
                      <xsl:choose>
                        <xsl:when test="$aff"><xsl:apply-templates select="$aff/node()"/></xsl:when>
                        <xsl:otherwise><span class="u-missing">[Affiliation not found: <xsl:value-of select="."/>]</span></xsl:otherwise>
                      </xsl:choose>
                    </li>
                  </xsl:for-each>
                </ul>
              </xsl:when>
              <xsl:otherwise><p>None declared.</p></xsl:otherwise>
            </xsl:choose>
          </div>
          
          <!-- Competing Interests -->
          <div class="popover-section">
            <div class="section-title">Competing Interests</div>
            <xsl:choose>
              <xsl:when test="$has-comp">
                <xsl:choose>
                  <xsl:when test="notes"><xsl:apply-templates select="notes/node()"/></xsl:when>
                  <xsl:when test="../../author-notes//fn[@fn-type='conflict']">
                    <xsl:for-each select="../../author-notes//fn[@fn-type='conflict']">
                      <p><xsl:apply-templates/></p>
                    </xsl:for-each>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise><p>None declared.</p></xsl:otherwise>
            </xsl:choose>
          </div>
          
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
</xsl:stylesheet>