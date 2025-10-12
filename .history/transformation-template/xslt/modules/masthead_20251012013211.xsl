<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink"
exclude-result-prefixes="xlink">

  <!-- Masthead -->
  <xsl:template match="front" mode="masthead">
    <header class="article-header">
      
      <!-- Volume + Year -->
      <!-- locally derive raw volume and year -->
      <xsl:variable name="raw-vol" select="normalize-space(article-meta/volume)"/>
      <xsl:variable name="yr">
        <xsl:choose>
          <!-- prefer explicit year if you have that element -->
          <xsl:when test="normalize-space(article-meta/year)!=''">
            <xsl:value-of select="normalize-space(article-meta/year)"/>
          </xsl:when>
          <!-- fallback to epub year, then any pub-date year -->
          <xsl:when test="normalize-space(article-meta/pub-date[@pub-type='epub']/year)!=''">
            <xsl:value-of select="normalize-space(article-meta/pub-date[@pub-type='epub']/year)"/>
          </xsl:when>
          <xsl:when test="normalize-space(article-meta/pub-date/year)!=''">
            <xsl:value-of select="normalize-space(article-meta/pub-date/year)"/>
          </xsl:when>
          <!-- final fallback -->
          <xsl:otherwise>2025</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <ul class="volume-year" aria-label="Volume and year">
        <li class="volume">
          <xsl:choose>
            <xsl:when test="$raw-vol!=''">
              <xsl:text>Vol </xsl:text>
              <xsl:call-template name="pad-volume">
                <xsl:with-param name="vol" select="$raw-vol"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>Unspecified Volume</xsl:otherwise>
          </xsl:choose>
        </li>
        <li class="year">
          <xsl:value-of select="$yr"/>
        </li>
      </ul>
      
      <div class="title-subtitle-authors-wrapper">
        <h1 class="article-title">
          <xsl:apply-templates select="article-meta/title-group/article-title"/>
        </h1>
        <xsl:if test="article-meta/title-group/subtitle">
          <h2 class="article-subtitle">
            <xsl:apply-templates select="article-meta/title-group/subtitle"/>
          </h2>
        </xsl:if>
  
        <!-- Author chips -->
        <ul class="authors">
          <xsl:for-each select="article-meta/contrib-group/contrib[@contrib-type='author']">
            
            <!-- ids to wire button ↔ panel -->
            <xsl:variable name="aid"     select="generate-id()"/>
            <xsl:variable name="panelId" select="concat('author-pop-', $aid)"/>
            <xsl:variable name="labelId" select="concat('author-label-', $aid)"/>
  
            <!-- ORCID resolution -->
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
  
            <!-- Presence flags (still useful for branch logic inside sections) -->
            <xsl:variable name="has-corresp" select="boolean(xref[@ref-type='corresp'])"/>
            <xsl:variable name="has-orcid"   select="string-length(normalize-space($orcid-url)) &gt; 0"/>
            <xsl:variable name="has-aff"     select="boolean(xref[@ref-type='aff'])"/>
            <xsl:variable name="has-comp"    select="boolean(notes) or boolean(../../author-notes//fn[@fn-type='conflict'])"/>
  
            <li class="author-chip">
              <!-- The interactive “chip” -->
              <button type="button"
                      class="chip popover-trigger"
                      aria-haspopup="dialog"
                      aria-expanded="false"
                      aria-controls="{$panelId}">
                <span id="{$labelId}">
                  <xsl:value-of select="normalize-space(name/given-names)"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(name/surname)"/>
                </span>
  
                <!-- Corresponding marker beside the name, if present -->
                <xsl:if test="$has-corresp">
                  <span class="corresp" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12.8333 7H9.33334L8.16667 8.75H5.83334L4.66667 7H1.16667" stroke="#43423E" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M3.17917 2.98084L1.16667 7.00001V10.5C1.16667 10.8094 1.28959 11.1062 1.50838 11.325C1.72717 11.5438 2.02392 11.6667 2.33334 11.6667H11.6667C11.9761 11.6667 12.2728 11.5438 12.4916 11.325C12.7104 11.1062 12.8333 10.8094 12.8333 10.5V7.00001L10.8208 2.98084C10.7243 2.78647 10.5754 2.62289 10.3909 2.50851C10.2064 2.39412 9.99372 2.33346 9.77667 2.33334H4.22334C4.00629 2.33346 3.79358 2.39412 3.60911 2.50851C3.42465 2.62289 3.27576 2.78647 3.17917 2.98084V2.98084Z" stroke="#43423E" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                  </span>
                </xsl:if>
              </button>
  
              <!-- ORCID icon link (decorative img; accessible name on link) -->
              <xsl:if test="$has-orcid">
                <a class="orcid" href="{$orcid-url}" rel="noopener" target="_blank"
                  aria-label="ORCID: {substring-after($orcid-url,'orcid.org/')}">
                  <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <g clip-path="url(#clip0_1_9013)">
                      <path d="M14 7C14 10.8664 10.8664 14 7 14C3.13359 14 0 10.8664 0 7C0 3.13359 3.13359 0 7 0C10.8664 0 14 3.13359 14 7Z" fill="#A6CE39"/>
                      <path d="M4.71954 10.1828H3.87735V4.32578H4.71954V6.97265V10.1828Z" fill="white"/>
                      <path d="M5.95547 4.32578H8.23047C10.3961 4.32578 11.3477 5.87343 11.3477 7.25703C11.3477 8.76093 10.1719 10.1883 8.24141 10.1883H5.95547V4.32578ZM6.79766 9.42812H8.13751C10.0461 9.42812 10.4836 7.9789 10.4836 7.25703C10.4836 6.08124 9.73438 5.08593 8.09376 5.08593H6.79766V9.42812Z" fill="white"/>
                      <path d="M4.85078 3.10624C4.85078 3.40702 4.60469 3.65858 4.29844 3.65858C3.99219 3.65858 3.74609 3.40702 3.74609 3.10624C3.74609 2.79999 3.99219 2.55389 4.29844 2.55389C4.60469 2.55389 4.85078 2.80546 4.85078 3.10624Z" fill="white"/>
                    </g>
                    <defs>
                      <clipPath id="clip0_1_9013">
                        <rect width="14" height="14" fill="white"/>
                      </clipPath>
                    </defs>
                  </svg>
                </a>
              </xsl:if>
  
            </li>
          </xsl:for-each>
        </ul>
      </div>
    
      <!-- Article Publication Date + Article Type + DOI link -->
      <div class="pub-date-article-type-doi-wrapper">
        
        <!-- Publication Date + Article Subject/Type -->
        <ul class="pub-date-and-article-type">
          <xsl:if test="article-meta/pub-date[@pub-type='epub']">
            <li>
              <time datetime="{article-meta/pub-date[@pub-type='epub']/@iso-8601-date}">
                
                <!-- MONTH -->
                <xsl:variable name="m" select="normalize-space(article-meta/pub-date[@pub-type='epub']/month)"/>
                <xsl:choose>
                  <xsl:when test="$m='01' or $m='1'">JAN</xsl:when>
                  <xsl:when test="$m='02' or $m='2'">FEB</xsl:when>
                  <xsl:when test="$m='03' or $m='3'">MAR</xsl:when>
                  <xsl:when test="$m='04' or $m='4'">APR</xsl:when>
                  <xsl:when test="$m='05' or $m='5'">MAY</xsl:when>
                  <xsl:when test="$m='06' or $m='6'">JUN</xsl:when>
                  <xsl:when test="$m='07' or $m='7'">JUL</xsl:when>
                  <xsl:when test="$m='08' or $m='8'">AUG</xsl:when>
                  <xsl:when test="$m='09' or $m='9'">SEP</xsl:when>
                  <xsl:when test="$m='10'">OCT</xsl:when>
                  <xsl:when test="$m='11'">NOV</xsl:when>
                  <xsl:when test="$m='12'">DEC</xsl:when>
                  <xsl:otherwise>UNK</xsl:otherwise>
                </xsl:choose>
                
                <!-- SPACE + DAY -->
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(article-meta/pub-date[@pub-type='epub']/day)"/>
                
                <!-- SPACE + YEAR -->
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(article-meta/pub-date[@pub-type='epub']/year)"/>
              </time>
            </li>
          </xsl:if>
          
          <!-- NEW: Article subjects -->
          <xsl:if test="article-meta/article-categories/subj-group/subject">
            <li class="article-subjects">
              <xsl:for-each select="article-meta/article-categories/subj-group/subject">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:if test="position()!=last()"><xsl:text>; </xsl:text></xsl:if>
              </xsl:for-each>
            </li>
          </xsl:if>
        </ul>
  
          <!-- DOI link -->
        <ul class="doi">
          <xsl:if test="article-meta/article-id[@pub-id-type='doi']">
            <li>
              <span>
                DOI:
              </span>
              <a class="doi"
                href="https://doi.org/{normalize-space(article-meta/article-id[@pub-id-type='doi'])}"
                target="_blank" rel="noopener">
                <xsl:value-of select="normalize-space(article-meta/article-id[@pub-id-type='doi'])"/>
              </a>
            </li>
          </xsl:if>
        </ul>

      </div>
    </header>
  </xsl:template>

</xsl:stylesheet>