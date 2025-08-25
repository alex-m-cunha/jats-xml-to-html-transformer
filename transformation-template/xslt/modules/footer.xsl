<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink"
exclude-result-prefixes="xlink">
    
   
    <xsl:template match="journal-meta" mode="footer">
        <footer class="site-footer" role="banner">

            <!-- Variables for ISSNs -->
            <xsl:variable name="journal-name" select="normalize-space(journal-title-group/journal-title)"/>
            <xsl:variable name="issn-online" select="normalize-space(issn[@pub-type='epub'][1])" />
            <xsl:variable name="issn-print" select="normalize-space(issn[@pub-type='ppub'][1])" />

            <div class="footer-wrap" role="contentinfo">

                <!-- =================== TOP ROW =================== -->
                <div class="footer-top">

                    <!-- Left: Journal Logo + ISSNs + Publisher -->
                    <div class="footer-left">

                        <!-- Journal Logo -->
                        <div class="journal-brand">

                            <img src="{$assets-path}img/journal-logo.svg" alt="{$journal-name}" aria-hidden="true" class="journal-logo" />
                            
                            <!-- Optional subtitle / society line (static placeholder for now) -->
                            <div class="journal-text">
                                <p class="journal-subtitle">[Society / Imprint Name]</p>
                            </div>

                        </div>

                        <!-- ISSNs -->
                        <div class="issns">
                            <p>
                                <strong>Online ISSN:</strong>
                                <xsl:choose>
                                    <xsl:when test="$issn-online!=''">
                                        <xsl:value-of select="$issn-online" />
                                    </xsl:when>
                                    <xsl:otherwise>—</xsl:otherwise>
                                </xsl:choose>
                            </p>
                            <p>
                                <strong>Print ISSN:</strong>
                                <xsl:choose>
                                    <xsl:when test="$issn-print!=''">
                                        <xsl:value-of select="$issn-print" />
                                    </xsl:when>
                                    <xsl:otherwise>—</xsl:otherwise>
                                </xsl:choose>
                            </p>
                        </div>

                        <!-- Publisher block -->
                        <div class="publisher-block">
                            <img src="{$assets-path}img/publisher-logo.svg" alt="Stanford University Press" class="publisher-logo" />
                            <address class="publisher-address">485 Broadway, First Floor, Redwood City, CA 94063-3136, USA.</address>
                        </div>
                    </div>

                    <!-- Right: Hosting by PKP -->
                    <div class="footer-right">
                        <img src="{$assets-path}img/hosting-by-pkp.svg" alt="Hosting by the Public Knowledge Project" class="hosting-by" />
                    </div>
                </div>

                <!-- Divider (style with border-top in CSS) -->
                <div class="footer-separator" role="separator" aria-hidden="true"></div>

                <!-- =================== BOTTOM ROW =================== -->
                <div class="footer-bottom">
                    <!-- License text -->
                    <img src="{$assets-path}img/cc-by-nc-4.0.svg" alt="Creative Commons BY-NC 4.0" />
                    <span class="license-line">
                        Content on this website is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License
                        <a href="https://creativecommons.org/licenses/by-nc/4.0/" target="_blank" rel="noopener">
                           CC BY-NC 4.0
                        </a>
                        except where otherwise stated.
                    </span>
                </div>
            </div>
        </footer>
    </xsl:template>
</xsl:stylesheet>