<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">
  
  <!-- expects a named template `graphic-src` (in utils) and optional param $img-root -->
  
  <xsl:template match="fig">
    <!-- Stable @id -->
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('fig-', generate-id())"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Figure label text: <label> > id like fN > global count -->
    <xsl:variable name="fig-label-text">
      <xsl:choose>
        <xsl:when test="normalize-space(label)!=''">
          <xsl:value-of select="normalize-space(label)"/>
        </xsl:when>
        <xsl:when test="starts-with(@id,'f')">
          <xsl:text>Figure </xsl:text>
          <!-- strip letters, keep digits from id -->
          <xsl:value-of select="translate(@id,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Figure </xsl:text>
          <xsl:value-of select="count(preceding::fig) + 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Best single <graphic> to render -->
    <xsl:variable name="g"
      select="(alternatives/graphic[@specific-use='online']
      | graphic
      | alternatives/graphic)[1]"/>
    
    <!-- alt text preference: graphic/alt-text > fig/alt-text -->
    <xsl:variable name="alt">
      <xsl:choose>
        <xsl:when test="($g/alt-text)">
          <xsl:value-of select="normalize-space($g/alt-text[1])"/>
        </xsl:when>
        <xsl:when test="alt-text">
          <xsl:value-of select="normalize-space(alt-text[1])"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Resolve image URL via your utils:graphic-src -->
    <xsl:variable name="src">
      <xsl:call-template name="graphic-src">
        <xsl:with-param name="href" select="$g/@xlink:href"/>
      </xsl:call-template>
    </xsl:variable>
    
    <figure id="{$id}" class="figure" role="figure" aria-labelledby="{$id}-cap">
      
      <div class="figure-actions" aria-label="Figure actions">
        <!-- Left: prev/next grouped controls -->
        <div class="figure-nav" role="group" aria-label="Figure navigation">
          <!-- Previous -->
          <button type="button"
            class="btn btn-icon prev-figure"
            aria-label="Previous figure"
            data-figure-nav="prev">
            <!-- left chevron -->
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
              width="16" height="16" aria-hidden="true" focusable="false">
              <path d="M15.41 7.41 14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
            </svg>
          </button>
          
          <!-- Next -->
          <button type="button"
            class="btn btn-icon next-figure"
            aria-label="Next figure"
            data-figure-nav="next">
            <!-- right chevron -->
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
              width="16" height="16" aria-hidden="true" focusable="false">
              <path d="M8.59 16.59 10 18l6-6-6-6-1.41 1.41L13.17 12z"/>
            </svg>
          </button>
        </div>
        
        <!-- Right: fullscreen/open image -->
        <xsl:if test="string-length(normalize-space($src)) &gt; 0">
          <a class="btn btn-icon open-image"
            href="{$src}"
            target="_blank"
            rel="noopener"
            aria-label="Open figure image in new tab (Fullscreen)">
            <!-- fullscreen icon -->
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
              width="16" height="16" aria-hidden="true" focusable="false">
              <path d="M7 14H5v5h5v-2H7v-3zm0-4h3V7h2V5H7v5zm10 7h-3v2h5v-5h-2v3zm0-11V5h-5v2h3v3h2V6z"/>
            </svg>
            <span class="btn-label">Fullscreen</span>
          </a>
        </xsl:if>
      </div>
      
      <!-- 2) Label line above media -->
      <div class="figure-labelline">
        <strong class="fig-label">
          <xsl:value-of select="$fig-label-text"/>
          <xsl:text>.</xsl:text>
        </strong>
      </div>
      
      <!-- 3) Media -->
      <div class="figure-media">
        <xsl:if test="string-length(normalize-space($src)) &gt; 0">
          <img src="{$src}">
            <!-- Only emit alt when we actually have text -->
            <xsl:if test="string-length(normalize-space($alt)) &gt; 0">
              <xsl:attribute name="alt"><xsl:value-of select="$alt"/></xsl:attribute>
            </xsl:if>
          </img>
        </xsl:if>
      </div>
      
      <!-- 4) Caption + 5) Description -->
      <figcaption id="{$id}-cap">
        <!-- Caption title -->
        <xsl:if test="normalize-space(caption/title)!=''">
          <p class="fig-caption">
            <xsl:value-of select="normalize-space(caption/title)"/>
          </p>
        </xsl:if>
        
        <!-- Description (extra caption text and stray <p> under <fig>) -->
        <xsl:for-each select="caption/*[not(self::title)] | p">
          <p class="fig-description"><xsl:apply-templates/></p>
        </xsl:for-each>
        
        <!-- Source/attrib (optional) -->
        <xsl:if test="attrib">
          <p class="fig-attrib"><em>Source:</em> <xsl:apply-templates select="attrib/node()"/></p>
        </xsl:if>
      </figcaption>
    </figure>
  </xsl:template>
  
</xsl:stylesheet>