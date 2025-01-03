#!/bin/bash
# created by curtthecoder, for fun
# Function to check if the site is legit
check_site() {
    local url=$1

    echo "Checking $url..."

    # Perform the curl command with verbose output
    curl -v -I -L --max-redirs 5 --tlsv1.2 --tls-max 1.3 "$url" 2>&1 | tee /tmp/curl_output.txt

    # Analyze the output
    echo -e "\nAnalysis:"

    # Check SSL/TLS certificate
    if grep -q "SSL certificate verify ok" /tmp/curl_output.txt; then
        echo "✅ SSL/TLS Certificate is valid."
    else
        echo "❌ SSL/TLS Certificate is invalid or not trusted."
    fi

    # Check HTTP headers
    if grep -qi "Strict-Transport-Security" /tmp/curl_output.txt; then
        echo "✅ Strict-Transport-Security header is present."
    else
        echo "❌ Strict-Transport-Security header is missing."
    fi

    if grep -qi "Content-Security-Policy" /tmp/curl_output.txt; then
        echo "✅ Content-Security-Policy header is present."
    else
        echo "❌ Content-Security-Policy header is missing."
    fi

    if grep -qi "X-Content-Type-Options" /tmp/curl_output.txt; then
        echo "✅ X-Content-Type-Options header is present."
    else
        echo "❌ X-Content-Type-Options header is missing."
    fi

    if grep -qi "X-Frame-Options" /tmp/curl_output.txt; then
        echo "✅ X-Frame-Options header is present."
    else
        echo "❌ X-Frame-Options header is missing."
    fi

    # Check response code
    if grep -q "HTTP/2 200" /tmp/curl_output.txt; then
        echo "✅ Site is accessible (HTTP 200 OK)."
    else
        echo "❌ Site is not accessible or returned an error."
    fi

    # Check for redirects
    if grep -qi "Location:" /tmp/curl_output.txt; then
        echo "🔄 Site redirects to another location."
    grep -i "Location:" /tmp/curl_output.txt | sed 's/.*Location: //i'
     else
    echo "➡️ Site does not redirect."
    fi
    # Check for WAF
    if grep -qi "Server: Cloudflare" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: Cloudflare"
    elif grep -qi "Server: AkamaiGHost" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: Akamai"
    elif grep -qi "Server: AWSALB" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: AWS WAF"
    elif grep -qi "Server: Barracuda" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: Barracuda"
    elif grep -qi "Server: F5" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: F5"
    elif grep -qi "Server: Imperva" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: Imperva"
    elif grep -qi "Server: Sucuri" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: Sucuri"
    elif grep -qi "Server: FortiWeb" /tmp/curl_output.txt; then
        echo "🛡️ WAF Detected: Fortinet FortiWeb"
    else
        echo "🛡️ No WAF Detected."
    fi

    # Summary
    echo -e "\nSummary:"
    if grep -q "SSL certificate verify ok" /tmp/curl_output.txt && grep -q "HTTP/2 200" /tmp/curl_output.txt; then
        echo "The site appears to be legitimate and accessible."
    else
        echo "The site may have issues. Please review the detailed analysis above."
    fi

    if grep -q "Location:" /tmp/curl_output.txt; then
        echo "The site redirects to another location. Ensure the redirect is to a trusted URL."
    fi

    if grep -qi "Strict-Transport-Security" /tmp/curl_output.txt && grep -qi "Content-Security-Policy" /tmp/curl_output.txt && grep -qi "X-Content-Type-Options" /tmp/curl_output.txt && grep -qi "X-Frame-Options" /tmp/curl_output.txt; then
        echo "The site has important security headers in place."
    else
        echo "The site is missing some important security headers. This could be a concern."
    fi

    if grep -qi "Server: Cloudflare" /tmp/curl_output.txt || grep -qi "Server: AkamaiGHost" /tmp/curl_output.txt || grep -qi "Server: AWSALB" /tmp/curl_output.txt || grep -qi "Server: Barracuda" /tmp/curl_output.txt || grep -qi "Server: F5" /tmp/curl_output.txt || grep -qi "Server: Imperva" /tmp/curl_output.txt || grep -qi "Server: Sucuri" /tmp/curl_output.txt || grep -qi "Server: FortiWeb" /tmp/curl_output.txt; then
        echo "The site is protected by a Web Application Firewall (WAF)."
    else
        echo "The site does not appear to be protected by a Web Application Firewall (WAF)."
    fi

    # Clean up
    rm /tmp/curl_output.txt
}

# Main script
if [ -z "$1" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

check_site "$1"
