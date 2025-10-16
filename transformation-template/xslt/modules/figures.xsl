<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">
  
  <!-- expects a named template `graphic-src` (in utils) and optional param $article-img -->
  
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
      
      <!-- Compute number of images/supplements for this figure -->
      <xsl:variable name="supp-count"
        select="count(graphic | alternatives/graphic | supplementary-material//graphic)"/>
      <xsl:variable name="has-supp" select="$supp-count &gt; 1"/>
      
      <div class="figure-actions" aria-label="Figure actions" data-supp-count="{$supp-count}">
        <!-- Left: prev/next grouped controls -->
        <div class="figure-nav" role="group" aria-label="Figure navigation">
          <!-- Previous -->
          <button type="button"
            class="btn btn-icon prev-figure">
            <xsl:attribute name="class">
              <xsl:text>btn btn-icon prev-figure </xsl:text>
              <xsl:choose>
                <xsl:when test="$has-supp">is-active</xsl:when>
                <xsl:otherwise>is-inactive</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="aria-label">Previous figure image</xsl:attribute>
            <xsl:attribute name="aria-disabled">
              <xsl:choose>
                <xsl:when test="$has-supp">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:if test="not($has-supp)">
              <xsl:attribute name="disabled">disabled</xsl:attribute>
              <xsl:attribute name="tabindex">-1</xsl:attribute>
            </xsl:if>
            <svg viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
              <path d="M10.5 12.4542L6.5 8.45422L10.5 4.45422" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
          
          <!-- Next -->
          <button type="button"
            class="btn btn-icon next-figure">
            <xsl:attribute name="class">
              <xsl:text>btn btn-icon next-figure </xsl:text>
              <xsl:choose>
                <xsl:when test="$has-supp">is-active</xsl:when>
                <xsl:otherwise>is-inactive</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="aria-label">Next figure image</xsl:attribute>
            <xsl:attribute name="aria-disabled">
              <xsl:choose>
                <xsl:when test="$has-supp">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:if test="not($has-supp)">
              <xsl:attribute name="disabled">disabled</xsl:attribute>
              <xsl:attribute name="tabindex">-1</xsl:attribute>
            </xsl:if>
            <svg viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
              <!-- right chevron -->
              <path d="M5.5 12.4542L9.5 8.45422L5.5 4.45422" stroke="#43423E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
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
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none"
              xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
              <path d="M5.83333 2.45422V4.45422C5.83333 4.80785 5.69286 5.14698 5.44281 5.39703C5.19276 5.64708 4.85362 5.78756 4.5 5.78756H2.5M14.5 5.78756H12.5C12.1464 5.78756 11.8072 5.64708 11.5572 5.39703C11.3071 5.14698 11.1667 4.80785 11.1667 4.45422V2.45422M11.1667 14.4542V12.4542C11.1667 12.1006 11.3071 11.7615 11.5572 11.5114C11.8072 11.2614 12.1464 11.1209 12.5 11.1209H14.5M2.5 11.1209H4.5C4.85362 11.1209 5.19276 11.2614 5.44281 11.5114C5.69286 11.7615 5.83333 12.1006 5.83333 12.4542V14.4542"
                stroke="#43423E" stroke-width="1.36364" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <span class="btn-label">Fullscreen</span>
          </a>
        </xsl:if>
      </div>
      
      <!-- 2) Label line above media -->
      <div class="figure-labelline">
        <strong class="fig-label">
          <xsl:value-of select="$fig-label-text"/>
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