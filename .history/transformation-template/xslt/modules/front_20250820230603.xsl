<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">

  <!-- Header masthead -->
  <xsl:template match="front" mode="masthead">
    <header class="article-header">
      <h1 class="article-title">
        <xsl:value-of select="article-meta/title-group/article-title"/>
      </h1>

      <!-- Author chips -->
      <ol class="authors">
        <xsl:for-each select="article-meta/contrib-group/contrib[@contrib-type='author']">
          <!-- Unique ids per author for wiring button ↔ panel -->
          <xsl:variable name="aid" select="generate-id()"/>
          <xsl:variable name="panelId" select="concat('author-pop-', $aid)"/>
          <xsl:variable name="labelId" select="concat('author-label-', $aid)"/>

          <!-- Compute ORCID (id or URL) -->
          <xsl:variable name="orcid-id" select="normalize-space(contrib-id[@contrib-id-type='orcid'][1])"/>
          <xsl:variable name="orcid-url">
            <xsl:choose>
              <xsl:when test="string-length($orcid-id)&gt;0">
                <xsl:choose>
                  <xsl:when test="contains($orcid-id,'http')"><xsl:value-of select="$orcid-id"/></xsl:when>
                  <xsl:otherwise>https://orcid.org/<xsl:value-of select="$orcid-id"/></xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test=".//(ext-link|uri)[contains(@xlink:href,'orcid.org')]">
                <xsl:value-of select=".//(ext-link|uri)[contains(@xlink:href,'orcid.org')][1]/@xlink:href"/>
              </xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:variable>

          <!-- Render author chip -->
          <li class="author-chip">
            <!-- The interactive control -->
            <button type="button"
                    class="chip"
                    aria-haspopup="dialog"
                    aria-expanded="false"
                    aria-controls="{$panelId}">
              <span id="{$labelId}">
                <xsl:value-of select="normalize-space(name/given-names)"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(name/surname)"/>
              </span>

              <!-- Corresponding author marker -->
              <xsl:if test=".//xref[@ref-type='corresp']">
                <span class="corresp" aria-hidden="true">✉</span>
              </xsl:if>

              <!-- ORCID icon as link (decorative img; accessible name on link) -->
              <xsl:if test="string-length(normalize-space($orcid-url)) &gt; 0">
                <a class="orcid" href="{$orcid-url}" rel="noopener" target="_blank"
                  aria-label="ORCID: {substring-after($orcid-url,'orcid.org/')}">
                  <img src="{$assets-path}img/orcid.svg" alt="" width="16" height="16"/>
                </a>
              </xsl:if>
            </button>

            <!-- Popover panel (initially hidden; your JS will toggle visibility + aria-expanded) -->
            <div id="{$panelId}"
                class="author-popover"
                role="dialog"
                aria-modal="false"
                aria-labelledby="{$labelId}"
                hidden="hidden">
              <div class="popover-header">
                <strong><xsl:value-of select="normalize-space(name/given-names)"/> <xsl:value-of select="normalize-space(name/surname)"/></strong>
                <button type="button" class="popover-close" aria-label="Close">×</button>
              </div>

              <!-- Affiliations resolved from xref rid → aff/@id -->
              <xsl:if test="xref[@ref-type='aff']">
                <div class="popover-section">
                  <div class="section-title">Affiliation</div>
                  <ul class="aff-list">
                    <xsl:for-each select="xref[@ref-type='aff']/@rid">
                      <li>
                        <xsl:variable name="aff" select="key('affById', .)[1]"/>
                        <xsl:choose>
                          <xsl:when test="$aff">
                            <xsl:apply-templates select="$aff/node()"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <span class="u-missing">[Affiliation not found: <xsl:value-of select="."/>]</span>
                          </xsl:otherwise>
                        </xsl:choose>
                      </li>
                    </xsl:for-each>
                  </ul>
                </div>
              </xsl:if>

              <!-- Competing interests (best-effort; varies by JATS) -->
              <xsl:if test="notes | (../..//author-notes//fn[@fn-type='conflict'])">
                <div class="popover-section">
                  <div class="section-title">Competing interests</div>
                  <xsl:choose>
                    <!-- Per-contrib notes, if present -->
                    <xsl:when test="notes">
                      <xsl:apply-templates select="notes/node()"/>
                    </xsl:when>
                    <!-- Fallback to any conflict statements in author-notes -->
                    <xsl:when test="../../author-notes//fn[@fn-type='conflict']">
                      <xsl:for-each select="../../author-notes//fn[@fn-type='conflict']">
                        <p><xsl:apply-templates/></p>
                      </xsl:for-each>
                    </xsl:when>
                  </xsl:choose>
                </div>
              </xsl:if>
            </div>
          </li>
        </xsl:for-each>
      </ol>

      <!-- Meta line: DOI + date -->
      <p class="meta">
        <xsl:if test="article-meta/article-id[@pub-id-type='doi']">
          <a class="doi"
             href="https://doi.org/{normalize-space(article-meta/article-id[@pub-id-type='doi'])}">
            DOI: <xsl:value-of select="normalize-space(article-meta/article-id[@pub-id-type='doi'])"/>
          </a>
          <span aria-hidden="true"> · </span>
        </xsl:if>
        <xsl:if test="article-meta/pub-date[@pub-type='epub']">
          <time datetime="{article-meta/pub-date[@pub-type='epub']/@iso-8601-date}">
            <xsl:value-of select="normalize-space(article-meta/pub-date[@pub-type='epub']/year)"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="normalize-space(article-meta/pub-date[@pub-type='epub']/month)"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="normalize-space(article-meta/pub-date[@pub-type='epub']/day)"/>
          </time>
        </xsl:if>
      </p>
    </header>
  </xsl:template>

  <!-- Abstract card for main column -->
  <xsl:template match="front" mode="abstract">
    <xsl:if test="article-meta/abstract">
      <section class="card abstract">
        <h2>Abstract</h2>
        <xsl:apply-templates select="article-meta/abstract/node()"/>
      </section>
    </xsl:if>
  </xsl:template>

  <!-- Right column IDs panel -->
  <xsl:template match="article-meta" mode="id-panel">
    <section class="card">
      <h3>Identifiers</h3>
      <ul class="ids">
        <xsl:if test="article-id[@pub-id-type='doi']">
          <li><a href="https://doi.org/{normalize-space(article-id[@pub-id-type='doi'])}">DOI</a></li>
        </xsl:if>
        <xsl:if test="article-id[@pub-id-type='pmid']">
          <li><a href="https://pubmed.ncbi.nlm.nih.gov/{normalize-space(article-id[@pub-id-type='pmid'])}/">PubMed</a></li>
        </xsl:if>
        <xsl:if test="article-id[@pub-id-type='pmcid']">
          <li>
            <xsl:variable name="pmc" select="normalize-space(article-id[@pub-id-type='pmcid'])"/>
            <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/{concat(starts-with($pmc,'PMC')*$pmc,$pmc)}">PMC</a>
          </li>
        </xsl:if>
        <xsl:if test="article-id[@pub-id-type='publisher-id']">
          <li>Publisher ID: <xsl:value-of select="normalize-space(article-id[@pub-id-type='publisher-id'])"/></li>
        </xsl:if>
      </ul>
    </section>
  </xsl:template>

  <!-- Rights/license panel -->
  <xsl:template match="permissions" mode="rights">
    <section class="card">
      <h3>Rights</h3>
      <xsl:if test="license">
        <p>
          <xsl:text>License: </xsl:text>
          <xsl:choose>
            <xsl:when test="license/@xlink:href">
              <a href="{license/@xlink:href}"><xsl:value-of select="normalize-space(license)"/></a>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="normalize-space(license)"/></xsl:otherwise>
          </xsl:choose>
        </p>
      </xsl:if>
      <xsl:if test="copyright-statement">
        <p><xsl:value-of select="normalize-space(copyright-statement)"/></p>
      </xsl:if>
    </section>
  </xsl:template>

  <!-- Footer (publisher address) -->
  <xsl:template match="journal-meta" mode="footer">
    <div class="publisher">
      <xsl:apply-templates select="publisher/publisher-loc"/>
    </div>
  </xsl:template>

</xsl:stylesheet>