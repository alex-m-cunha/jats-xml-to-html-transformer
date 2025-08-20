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
          <li class="author-chip">
            <xsl:value-of select="normalize-space(name/given-names)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space(name/surname)"/>
            <!-- Corresponding marker if present -->
            <xsl:if test=".//xref[@ref-type='corresp']">
              <span class="corresp">✉</span>
            </xsl:if>
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