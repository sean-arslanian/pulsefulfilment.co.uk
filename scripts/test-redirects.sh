#!/usr/bin/env bash
# Usage: scripts/test-redirects.sh https://pulsefulfilment.co.uk
# Checks every old WordPress URL redirects (301) to the expected new URL and that it returns 200.
set -u
HOST="${1:?host required, e.g. https://pulsefulfilment.co.uk}"
pass=0; fail=0
while IFS='|' read -r old new; do
  [ -z "$old" ] && continue
  final=$(curl -s -o /dev/null -w '%{redirect_url}' "$HOST$old")
  code=$(curl -s -o /dev/null -w '%{http_code}' "$HOST$old")
  exp="$HOST$new"
  if [ "$old" = "$new" ] || [ "$old" = "${new}/" ]; then
    if [ "$code" = "200" ] || [ "$code" = "301" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL $old -> $code"; fi
    continue
  fi
  dest=$(curl -s -o /dev/null -w '%{http_code}' -L "$HOST$old")
  if [ "$code" = "301" ] && [ "${final%/}" = "${exp%/}" ] && [ "$dest" = "200" ]; then
    pass=$((pass+1))
  else
    fail=$((fail+1)); echo "FAIL $old -> $code $final (expected $exp, final $dest)"
  fi
done <<'EOF'
/|/
/pricing/|/pricing
/integrations/|/integrations
/news/|/news
/services/|/services
/contact-us/|/contact
/privacy-policy/|/privacy
/ecommerce-fulfilment/|/services
/returns-managment/|/services
/thank-you/|/contact
/value-added-services/|/services
/platinum/|/pricing
/gold/|/pricing
/silver/|/pricing
/bronze/|/pricing
/beauty-cosmetics-fulfilment/|/sectors
/health-supplements-fufilment/|/sectors
/pet-animal-supplies-fulfilment/|/sectors
/fashion-apparel-fulfilment/|/sectors
/electronics-fulfilment/|/sectors
/food-drink-fulfilment/|/sectors
/stationery-gifts-fulfilment/|/sectors
/luxury-goods-fulfilment/|/sectors
/music-media-fulfilment/|/sectors
/book-fulfilment/|/sectors
/subscription-box-fulfilment/|/sectors
/sporting-goods-fulfilment/|/sectors
/subscription-boxe-fulfilment/|/sectors
/ecommerce-fulfilment-liverpool/|/locations/liverpool
/amazon/|/integrations/amazon-fbm
/api/|/integrations/custom-api
/argos/|/integrations/argos
/bandcamp/|/integrations/bandcamp
/big-commerce/|/integrations/bigcommerce
/blue-park/|/integrations/bluepark
/bright-pearl/|/integrations/brightpearl
/channel-advisor/|/integrations/channeladvisor
/cs-cart/|/integrations/cs-cart
/dear-systems/|/integrations/dear-systems
/ebay-fulfilment/|/integrations/ebay
/ecwid/|/integrations/ecwid
/ekm-power-shop/|/integrations/ekm-powershop
/fruugo/|/integrations/fruugo
/ftp-import-export/|/integrations/ftp
/groupon/|/integrations/groupon
/lightspeed/|/integrations/lightspeed
/magento/|/integrations/magento
/mirkal/|/integrations/mirakl
/not-on-the-high-street/|/integrations/not-on-the-high-street
/oracle-netsuite/|/integrations/netsuite
/shopify/|/integrations/shopify
/shopwired/|/integrations/shopwired
/squarespace/|/integrations/squarespace
/the-range-market-place/|/integrations/the-range
/tiktok-shop/|/integrations/tiktok-shop
/veeqo/|/integrations/veeqo
/wayfair/|/integrations/wayfair
/wish/|/integrations/wish
/woo-commerce/|/integrations/woocommerce
/wowcher/|/integrations/wowcher
/zendesk/|/integrations/zendesk
/3dcart/|/integrations
/apc-overnight/|/integrations
/blue-jay-solutions/|/integrations
/channel-engine/|/integrations
/dhl-parcel/|/integrations
/fedex/|/integrations
/inventory-planner/|/integrations
/royal-mail/|/integrations
/sap-business-by-design/|/integrations
/store-feeder/|/integrations
/the-pallet-network/|/integrations
/virtual-stock/|/integrations
/volo/|/integrations
/volusion/|/integrations
/weebly/|/integrations
/yumbles/|/integrations
/zedonk/|/integrations
/2025/03/05/3pl-services-guide-benefits-types-how-to-choose/|/blog/how-to-choose-a-3pl
/category/uncategorised/|/blog
EOF
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
