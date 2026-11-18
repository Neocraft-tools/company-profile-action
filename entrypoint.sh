#!/usr/bin/env bash
# Official company profiles (registry data: FR SIREN, UK Companies House, US SEC, LEI) from names, domains or IDs.
set -euo pipefail
. "$(dirname "$0")/apify.sh"
check_prereqs

QUERIES="$(split_list "${INPUT_QUERIES:-}")"
[ "$(jq length <<<"$QUERIES")" -gt 0 ] || fail "Input 'queries' is required (domains, company names, SIREN, UK company numbers, ticker:XXX...)"

BASE="$(jq -c -n --argjson q "$QUERIES" --arg c "${INPUT_DEFAULT_COUNTRY:-ANY}" \
  --argjson web "$(bool "${INPUT_WEBSITE_LOOKUP:-}" true)" --argjson hire "$(bool "${INPUT_HIRING_SIGNALS:-}" false)" \
  '{queries: $q, defaultCountry: $c, websiteLookup: $web, hiringSignals: $hire}')"
INPUT="$(merge_extra "$BASE" "${INPUT_EXTRA_INPUT:-}")"

CAP="${INPUT_MAX_TOTAL_CHARGE_USD:-0.10}"
OUT="${INPUT_OUTPUT_FILE:-company-profiles.json}"
apify_run "neocraft~official-company-profile" "$INPUT" "$CAP" "${INPUT_TIMEOUT_SECS:-600}" "$OUT"

ROWS="$(jq -c '[.[] | select(.query != null and .status != null)]' "$OUT")"
FOUND="$(jq '[.[] | select(.status == "found")] | length' <<<"$ROWS")"
NOTFOUND="$(jq '[.[] | select(.status != "found")] | length' <<<"$ROWS")"
{
  echo "## Company profiles"
  echo
  echo "| Query | Status | Company | Country | Legal status | Incorporated | IDs |"
  echo "|---|---|---|---|---|---|---|"
  jq -r '.[] | "| \(.query) | \(.status)\(if .reason then " (" + (.reason | tostring | .[0:80]) + ")" else "" end) | \(.companyName // "") | \(.country // "") | \(.company.status // "") | \(.company.incorporationDate // "") | \((.ids // {}) | to_entries | map("\(.key): \(.value)") | join(", ") | gsub("\\|"; "/")) |"' <<<"$ROWS"
  echo
  echo "${FOUND} found, ${NOTFOUND} not found/ambiguous (not charged)."
} | summary
footer "$CAP"

set_output found-count "$FOUND"
set_output not-found-count "$NOTFOUND"
set_output profiles "$(jq -c 'map({query, status, companyName, country, ids, matchConfidence, legalStatus: .company.status, incorporationDate: .company.incorporationDate, address: .company.registeredAddress.full})' <<<"$ROWS" | head -c 60000)"

if [ "$NOTFOUND" -gt 0 ] && [ "$(bool "${INPUT_FAIL_ON_NOT_FOUND:-}" false)" = "true" ]; then
  echo "::error::${NOTFOUND} query(ies) did not resolve to a company"
  exit 1
fi
echo "Done: ${FOUND} profile(s) found"
