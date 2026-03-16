#!/bin/bash
# ============================================================
# MB Capital Strategies Global — URL Submission Script
# Submits all site URLs to Google, Bing, and IndexNow
# Run after deploying new content: bash submit-urls.sh
# ============================================================

DOMAIN="https://mbcapitalstrategiesgloabal.com"
INDEXNOW_KEY="9281296539de44729f00285e02a89b85"
SITEMAP_URL="${DOMAIN}/sitemap.xml"

# --- 1. Ping Google Sitemap ---
echo "=== Pinging Google with sitemap ==="
curl -s "https://www.google.com/ping?sitemap=${SITEMAP_URL}" -o /dev/null -w "Google ping: HTTP %{http_code}\n"

# --- 2. Ping Bing Sitemap ---
echo "=== Pinging Bing with sitemap ==="
curl -s "https://www.bing.com/ping?sitemap=${SITEMAP_URL}" -o /dev/null -w "Bing ping: HTTP %{http_code}\n"

# --- 3. IndexNow batch submission (Bing, Yandex, Naver, etc.) ---
echo "=== Submitting URLs via IndexNow ==="

# Collect all URLs from sitemap
URLS=$(grep -oP '(?<=<loc>)[^<]+' sitemap.xml 2>/dev/null)

if [ -z "$URLS" ]; then
    echo "No sitemap.xml found locally. Using hardcoded URL list."
    URLS=$(cat <<'URLLIST'
https://mbcapitalstrategiesgloabal.com/
https://mbcapitalstrategiesgloabal.com/pages/portfolio.html
https://mbcapitalstrategiesgloabal.com/pages/strategy.html
https://mbcapitalstrategiesgloabal.com/pages/dividend-strategy.html
https://mbcapitalstrategiesgloabal.com/pages/hard-asset-guide.html
https://mbcapitalstrategiesgloabal.com/pages/shipping.html
https://mbcapitalstrategiesgloabal.com/pages/pipelines.html
https://mbcapitalstrategiesgloabal.com/pages/mining.html
https://mbcapitalstrategiesgloabal.com/pages/energy.html
https://mbcapitalstrategiesgloabal.com/pages/upstream.html
https://mbcapitalstrategiesgloabal.com/pages/high-yield.html
https://mbcapitalstrategiesgloabal.com/pages/supercycles.html
https://mbcapitalstrategiesgloabal.com/pages/calculators.html
https://mbcapitalstrategiesgloabal.com/pages/podcast.html
https://mbcapitalstrategiesgloabal.com/pages/glossary.html
https://mbcapitalstrategiesgloabal.com/pages/blog.html
https://mbcapitalstrategiesgloabal.com/pages/about.html
https://mbcapitalstrategiesgloabal.com/pages/toolbox.html
URLLIST
)
fi

# Build JSON array of URLs
URL_JSON=$(echo "$URLS" | python3 -c "
import sys, json
urls = [line.strip() for line in sys.stdin if line.strip()]
print(json.dumps(urls))
")

# Submit to IndexNow API
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "https://api.indexnow.org/IndexNow" \
    -H "Content-Type: application/json" \
    -d "{
        \"host\": \"mbcapitalstrategiesgloabal.com\",
        \"key\": \"${INDEXNOW_KEY}\",
        \"keyLocation\": \"${DOMAIN}/${INDEXNOW_KEY}.txt\",
        \"urlList\": ${URL_JSON}
    }")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
echo "IndexNow submission: HTTP ${HTTP_CODE}"

# --- 4. Summary ---
URL_COUNT=$(echo "$URLS" | wc -l)
echo ""
echo "=== Summary ==="
echo "URLs submitted: ${URL_COUNT}"
echo "IndexNow key: ${INDEXNOW_KEY}"
echo ""
echo "Next steps:"
echo "  1. Verify your site in Google Search Console: https://search.google.com/search-console"
echo "  2. Submit sitemap there: ${SITEMAP_URL}"
echo "  3. Verify in Bing Webmaster Tools: https://www.bing.com/webmasters"
echo "  4. Re-run this script after publishing new content"
