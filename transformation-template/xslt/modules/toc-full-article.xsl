<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="1.0">
    
    <!-- Left column TOC (top-level sections only) -->
    <xsl:template match="body" mode="toc-full-article">
        <nav class="toc" aria-label="Table of Contents">
            <ul>
                <!-- Abstract -->
                <xsl:if test="/article/front/article-meta/abstract">
                    <xsl:variable name="abs" select="/article/front/article-meta/abstract"/>
                    <xsl:variable name="abs-id">abstract</xsl:variable>
                    
                    <!-- Label: use <title> if present; else "Abstract" -->
                    <xsl:variable name="abs-title">
                        <xsl:choose>
                            <xsl:when test="normalize-space($abs/title)!=''">
                                <xsl:value-of select="normalize-space($abs/title)"/>
                            </xsl:when>
                            <xsl:otherwise>Abstract</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <li>
                        <a href="#{$abs-id}">
                            <xsl:value-of select="$abs-title"/>
                        </a>
                    </li>
                </xsl:if>
                
                <!-- Body Sections -->
                <xsl:for-each select="sec">
                    <xsl:variable name="id">
                        <xsl:choose>
                            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <li>
                        <a href="#{$id}"><xsl:value-of select="normalize-space(title)"/></a>  
                    </li>
                </xsl:for-each>
                
                <!-- Appendix -->
                <xsl:if test="/article/back/sec/title = 'Appendix'">
                    <xsl:variable name="appendix-id">appendix</xsl:variable>
                    
                    <!-- Label: use <title> if present; else "Appendix" -->
                    <xsl:variable name="appendix-title">
                        <xsl:choose>
                            <xsl:when test="normalize-space(/article/back/sec/title)!=''">
                                <xsl:value-of select="normalize-space(/article/back/sec/title)"/>
                            </xsl:when>
                            <xsl:otherwise>Appendix</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <li>
                        <a href="#{$appendix-id}"><xsl:value-of select="$appendix-title"/></a>
                    </li>
                </xsl:if>
                
                <!-- References -->
                <xsl:if test="/article/back/ref-list">
                    <xsl:variable name="ref-list-id">references</xsl:variable>
                    
                    <!-- Label: use <title> if present; else "References" -->
                    <xsl:variable name="ref-list-title">
                        <xsl:choose>
                            <xsl:when test="normalize-space(/article/back/ref-list/title)!=''">
                                <xsl:value-of select="normalize-space(/article/back/ref-list/title)"/>
                            </xsl:when>
                            <xsl:otherwise>References</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <li>
                        <a href="#{$ref-list-id}"><xsl:value-of select="$ref-list-title"/></a>
                    </li>
                </xsl:if>
                
            </ul>
        </nav>
    </xsl:template>
    
</xsl:stylesheet>