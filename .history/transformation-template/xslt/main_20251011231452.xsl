<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">

  <!-- ===== Parameters ===== -->
  <xsl:param name="assets-path" select="'../../../../transformation-template/assets/'" />           <!-- CSS/JS relative folder -->
  <xsl:param name="pdf-href"/>                 
  <xsl:param name="article-img"/> <!-- ===== Parameters ===== -->  //
  <xsl:param name="debug" select="'no'"/>

  <!-- Tell the processor to generate HTML5-like output -->
  <xsl:output
    method="html"
    encoding="UTF-8"
    indent="yes"
    omit-xml-declaration="yes" />

  <!-- Strip ignorable whitespace to keep output clean -->
  <xsl:strip-space elements="*" />

  <!-- ===== Modules ===== -->
  <xsl:include href="modules/utils.xsl" />
  <xsl:include href="modules/inline.xsl" />
  <xsl:include href="modules/masthead.xsl" />
  <xsl:include href="modules/toc-full-article.xsl" />
  <xsl:include href="modules/full-article.xsl" />
  <xsl:include href="modules/toc-figures-tables.xsl"/>
  <xsl:include href="modules/figures-tables.xsl"/>
  <xsl:include href="modules/figures.xsl"/>
  <xsl:include href="modules/back.xsl"/>
  <xsl:include href="modules/right-sidebar.xsl"/>
  <xsl:include href="modules/publisher-header.xsl"/>
  <xsl:include href="modules/footer.xsl"/>
  <xsl:include href="modules/appendix.xsl"/>

  <!-- ===== Root template → full HTML page ===== -->
  <xsl:template match="/">
    <xsl:variable name="title"
      select="normalize-space(/article/front/article-meta/title-group/article-title)" />

    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>
          <xsl:choose>
            <xsl:when test="$title!=''">
              <xsl:value-of select="$title" />
            </xsl:when>
            <xsl:otherwise>Article</xsl:otherwise>
          </xsl:choose>
        </title>

        <!-- CSS -->
        <link rel="stylesheet" href="{$assets-path}css/base.css" />
        <link rel="stylesheet" href="{$assets-path}css/layout.css" />
        <link rel="stylesheet" href="{$assets-path}css/popovers.css" />
        <link rel="stylesheet" href="{$assets-path}css/publisher-header.css" />
        <link rel="stylesheet" href="{$assets-path}css/masthead.css" />
        <link rel="stylesheet" href="{$assets-path}css/sidebar.css" />
        <link rel="stylesheet" href="{$assets-path}css/toc.css" />
        <link rel="stylesheet" href="{$assets-path}css/footer.css" />
        <link rel="stylesheet" href="{$assets-path}css/fonts.css" />
        <link rel="stylesheet" href="{$assets-path}css/assets.css" />
      </head>

      <body>
        <a class="skip" href="#panel-full-article">Skip to content</a>

        <!-- Header -->
        <xsl:apply-templates select="/article/front/journal-meta" mode="publisher-header"/>

        <section class="main-container">
          
          <!-- ===================== Tabs: Full Article vs Figures & Tables ===================== -->
          <xsl:variable name="has-figures-tables"
            select="boolean(/article//fig or /article//table-wrap)"/>

          <!-- Main Container as CSS Grid -->
          <div class="main-content-wrapper">

            <div class="article-header-tabs-container">
              
              <!-- Masthead/Header -->
              <xsl:apply-templates select="/article/front" mode="masthead" />
              
              <!-- Tablist -->
              <nav class="tabs content-tabs" role="tablist" aria-label="Content views">
                <div class="content-tabs-wrapper">
                  <!-- Full Article tab -->
                  <button id="tab-full-article"
                    class="tab is-active"
                    role="tab"
                    aria-selected="true"
                    aria-controls="panel-full-article"
                    tabindex="0">
                    Full Article
                  </button>
                  
                  <!-- Figures & Tables tab (conditional) -->
                  <xsl:if test="$has-figures-tables">
                    <button id="tab-figures-tables"
                      class="tab"
                      role="tab"
                      aria-selected="false"
                      aria-controls="panel-figures-tables"
                      tabindex="-1">
                      Figures and Tables
                    </button>
                  </xsl:if>
                </div>
              </nav>
              
            </div>
            
            <!-- ===================== Panels (each panel contains its own TOC + content) ===================== -->
            <div class="panels">
              
              <section id="panel-full-article"
                class="panel is-active"
                role="tabpanel"
                aria-labelledby="tab-full-article">
                
                <div class="panel-grid">
                  
                  <!-- Left: TOC for Full Article -->
                  <aside class="toc-wrap" aria-label="Full Article Table of Contents">
                    <xsl:apply-templates select="/article/body" mode="toc-full-article"/>
                  </aside>
                  
                  <!-- Right: Full Article content -->
                  <main id="main-full-article" class="panel-content" role="region" aria-labelledby="tab-article">
                    <xsl:apply-templates select="/article/body" mode="full-article"/>
                  </main>
                </div>
              </section>
              
              <!-- ===== Panel: Figures & Tables (conditional) ===== -->
              <xsl:if test="$has-figures-tables">
                <section id="panel-figures-tables"
                  class="panel"
                  role="tabpanel"
                  aria-labelledby="tab-figures-tables"
                  hidden="hidden">
                  
                  <div class="panel-grid">
                    
                    <!-- Left: TOC for Figures & Tables (your H2-only version) -->
                    <aside class="toc-wrap" aria-label="Figures and Tables Table of Contents">
                      <xsl:apply-templates select="/article" mode="toc-figures-tables"/>
                    </aside>
                    
                    <!-- Right: Figures & Tables combined view -->
                    <main id="main-figures-tables" class="panel-content" role="region" aria-labelledby="tab-figures-tables">
                      <xsl:apply-templates select="/article" mode="figures-tables"/>
                    </main>
                  </div>
                </section>
              </xsl:if>
              
            </div>
            
          </div>
          
          <!-- Right Sidebar -->
          <aside class="right-sidebar" aria-label="Actions and metadata">
            <xsl:call-template name="right-sidebar"/>
          </aside>
          
          <!-- ===== Optional noscript fallback: show both panels if JS is disabled ===== -->
          <noscript>
            <style>
              .tabs { display:none }
              .panel { display:block !important }
              .panel[hidden] { display:block !important }
            </style>
          </noscript>
          
        </section>
        
        <!-- Hidden popover content for citations and footnotes -->
        <xsl:apply-templates select="/article/back/ref-list" mode="popovers"/>
        <xsl:apply-templates select="/article/back/fn-group" mode="popovers"/>
        <xsl:apply-templates select="/article" mode="author-popovers"/>

        <!-- Footer -->
        <xsl:apply-templates select="/article/front/journal-meta" mode="footer"/>

        <!-- JS (progressive enhancement) -->
        <script src="{$assets-path}js/popovers.js"></script>
        <script src="{$assets-path}js/tab-switching-functionality.js" defer="defer"></script>
        <script src="{$assets-path}js/toc.js" defer="defer"></script>
        <script src="{$assets-path}js/lightbox.js" defer="defer"></script>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>