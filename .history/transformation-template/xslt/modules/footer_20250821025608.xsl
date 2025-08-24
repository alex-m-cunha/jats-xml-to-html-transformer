<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="journal-meta" mode="footer">
        <footer class="site-footer">
            
            <!-- Footer (journal metadata → responsive blocks) -->
            <xsl:apply-templates select="/article/front/journal-meta" mode="footer"/>
            
            <!-- Variables for ISSNs -->
            <xsl:variable name="issn-online" select="normalize-space(issn[@pub-type='epub'][1])"/>
            <xsl:variable name="issn-print"  select="normalize-space(issn[@pub-type='ppub'][1])"/>

            <div class="footer-wrap" role="contentinfo">
                
                <!-- =================== TOP ROW =================== -->
                <div class="footer-top">
                    
                    <!-- Left: Journal branding + ISSNs + Publisher -->
                    <div class="footer-left">
                        
                        <!-- Journal mark/title -->
                        <div class="journal-brand">
                            
                            <!-- Optional journal logo (decorative) -->
                            <img src="{$assets-path}img/journal-mark.svg"
                                alt="" aria-hidden="true" class="journal-mark"/>
                            
                            <div class="journal-text">
                                <h2 class="journal-name">
                                    <xsl:choose>
                                    <xsl:when test="journal-title-group/journal-title">
                                        <xsl:value-of select="normalize-space(journal-title-group/journal-title)"/>
                                    </xsl:when>
                                    <xsl:otherwise>Journal Name</xsl:otherwise>
                                    </xsl:choose>
                                </h2>
                                <!-- Optional subtitle / society line (static placeholder for now) -->
                                <p class="journal-subtitle">[Society / Imprint Name]</p>
                            </div>
                            
                        </div>

                        <!-- ISSNs -->
                        <div class="issns">
                            <p>
                            <strong>Online ISSN:</strong>
                            <xsl:choose>
                                <xsl:when test="$issn-online!=''"><xsl:value-of select="$issn-online"/></xsl:when>
                                <xsl:otherwise>—</xsl:otherwise>
                            </xsl:choose>
                            </p>
                            <p>
                            <strong>Print ISSN:</strong>
                            <xsl:choose>
                                <xsl:when test="$issn-print!=''"><xsl:value-of select="$issn-print"/></xsl:when>
                                <xsl:otherwise>—</xsl:otherwise>
                            </xsl:choose>
                            </p>
                        </div>

                        <!-- Publisher block -->
                        <div class="publisher-block">
                            <img src="{$assets-path}img/publisher-logo.svg"
                                alt="Stanford University Press" class="publisher-logo"/>
                            <address class="publisher-address">
                            [Street Address], [Floor/Suite if any], [City],<br/>
                            [State], [ZIP Code], [Country]
                            </address>
                        </div>
                    </div>

                    <!-- Right: Hosting by PKP -->
                    <div class="footer-right">
                    <div class="hosting-label">Hosting by</div>
                        <a class="hosting-org" href="https://pkp.sfu.ca/" target="_blank" rel="noopener">
                            Public<br/>Knowledge<br/>Project
                        </a>
                    </div>
                </div>

                <!-- Divider (style with border-top in CSS) -->
                <div class="footer-separator" role="separator" aria-hidden="true"></div>

                <!-- =================== BOTTOM ROW =================== -->
                <div class="footer-bottom">
                    <!-- License icon row -->
                    <ul class="cc-icons" aria-label="License icons">
                        <li>
                            <img src="{$assets-path}img/cc.svg" alt="Creative Commons" width="20" height="20"/>
                        </li>
                        <li>
                            <img src="{$assets-path}img/cc-by.svg" alt="Attribution (BY)" width="20" height="20"/>
                        </li>
                        <li>
                            <img src="{$assets-path}img/cc-nc.svg" alt="NonCommercial (NC)" width="20" height="20"/>
                        </li>
                    </ul>

                    <!-- License text -->
                    <p class="license-line">
                        Content on this website is licensed under a Creative Commons
                        Attribution-NonCommercial 4.0 International License
                    <a href="https://creativecommons.org/licenses/by-nc/4.0/" target="_blank" rel="noopener">
                        CC BY-NC 4.0
                    </a>
                    except where otherwise stated.
                    </p>
                </div>
            </div>
        </footer>
  </xsl:template>
</xsl:stylesheet>