/**
 * Right Sidebar JavaScript functionality
 */

document.addEventListener('DOMContentLoaded', function() {
    // Handle copy to clipboard functionality
    const copyButtons = document.querySelectorAll('[data-copy]');
    
    copyButtons.forEach(button => {
        button.addEventListener('click', async function() {
            const targetSelector = this.getAttribute('data-copy');
            const targetElement = document.querySelector(targetSelector);
            
            if (!targetElement) {
                console.error('Copy target element not found:', targetSelector);
                return;
            }
            
            try {
                // Get the text content from the target element and normalize whitespace
                const textToCopy = targetElement.textContent
                    .trim()
                    .replace(/\s+/g, ' ')  // Replace multiple whitespace with single space
                    .replace(/\n+/g, ' ')  // Replace newlines with spaces
                    .replace(/\s*\.\s*/g, '. ')  // Normalize spacing around periods
                    .replace(/\s*,\s*/g, ', ')   // Normalize spacing around commas
                    .replace(/\s*\?\s*/g, '? ')  // Normalize spacing around question marks
                    .replace(/\s*!\s*/g, '! ')   // Normalize spacing around exclamation marks
                    .replace(/\s*;\s*/g, '; ')   // Normalize spacing around semicolons
                    .replace(/\s*:\s*/g, ': ');  // Normalize spacing around colons
                
                // Use the modern Clipboard API if available
                if (navigator.clipboard && window.isSecureContext) {
                    await navigator.clipboard.writeText(textToCopy);
                } else {
                    // Fallback for older browsers
                    const textArea = document.createElement('textarea');
                    textArea.value = textToCopy;
                    textArea.style.position = 'fixed';
                    textArea.style.left = '-999999px';
                    textArea.style.top = '-999999px';
                    document.body.appendChild(textArea);
                    textArea.focus();
                    textArea.select();
                    document.execCommand('copy');
                    textArea.remove();
                }
                
                // Visual feedback - temporarily change button text and style
                const originalText = this.querySelector('span').textContent;
                const spanElement = this.querySelector('span');
                const svgPaths = this.querySelectorAll('svg path');
                
                // Store original styles
                const originalBgColor = this.style.backgroundColor;
                const originalBorderColor = this.style.borderColor;
                const originalTextColor = this.style.color;
                const originalStrokeColor = svgPaths.length > 0 ? svgPaths[0].getAttribute('stroke') : null;
                
                // Apply success styling
                spanElement.textContent = 'Copied!';
                this.style.backgroundColor = '#f0f9f0'; // Very subtle green background
                this.style.borderColor = '#4ade80';     // Subtle green border
                this.style.color = '#4ade80';           // Green text color
                
                // Change SVG stroke to green
                svgPaths.forEach(path => {
                    path.setAttribute('stroke', '#4ade80');
                });
                
                // Reset button text and styling after 2 seconds
                setTimeout(() => {
                    spanElement.textContent = originalText;
                    this.style.backgroundColor = originalBgColor;
                    this.style.borderColor = originalBorderColor;
                    this.style.color = originalTextColor;
                    
                    // Reset SVG stroke
                    if (originalStrokeColor) {
                        svgPaths.forEach(path => {
                            path.setAttribute('stroke', originalStrokeColor);
                        });
                    }
                }, 2000);
                
            } catch (err) {
                console.error('Failed to copy text:', err);
                
                // Show error feedback
                const spanElement = this.querySelector('span');
                const originalText = spanElement.textContent;
                spanElement.textContent = 'Copy failed';
                
                setTimeout(() => {
                    spanElement.textContent = originalText;
                }, 2000);
            }
        });
    });
});