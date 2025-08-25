<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- Figures & Tables TOC (headings-as-links, same structure as toc-full-article.xsl) -->
    <xsl:template match="/article" mode="toc-figures-tables">
        <nav class="toc toc-figtab" aria-label="Figures and Tables TOC">
            <ul class="toc-list">
                <!-- Figures (only if present) -->
                <xsl:if test="//fig">
                    <li><a href="#all-figures">Figures</a></li>
                </xsl:if>
                
                <!-- Tables (only if present) -->
                <xsl:if test="//table-wrap">
                    <li><a href="#all-tables">Tables</a></li>
                </xsl:if>
            </ul>
        </nav>
    </xsl:template>
    
</xsl:stylesheet>