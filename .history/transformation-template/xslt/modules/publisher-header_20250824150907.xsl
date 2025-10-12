<?xml version="1.0" encoding="UTF-8"?>

    <xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xlink">
    
        <xsl:template match="journal-meta" mode="publisher-header">
            <xsl:variable name="journal-name" select="normalize-space(journal-title-group/journal-title)"/>
            
            <header class="journal-header" role="banner">
                
                <div class="header-wrap" role="contentinfo">
                    <img src="{$assets-path}img/journal-logo.svg" alt="{$journal-name}" class="journal-logo" />
                    <img src="{$assets-path}img/publisher-logo.svg" alt="Stanford University Press" class="publisher-logo" />
                </div>
                
            </header>
        </xsl:template>
    
    </xsl:stylesheet>