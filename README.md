# Official Company Profile GitHub Action: registry data from names, domains or IDs

[![GitHub release](https://img.shields.io/github/v/release/Neocraft-tools/company-profile-action)](https://github.com/Neocraft-tools/company-profile-action/releases)
[![Apify Actor](https://img.shields.io/badge/Apify-official--company--profile-blue)](https://apify.com/neocraft/official-company-profile)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Resolve company names, website domains or official identifiers into **official registry profiles**: legal name, IDs (SIREN/SIRET, VAT, UK company number, SEC CIK, LEI), legal form, status, incorporation date, address, activity code, size and published financials. Sources are public registries (France, United Kingdom, United States SEC, GLEIF); no LinkedIn scraping. Useful to enrich a CSV of leads or suppliers in CI, or to check a counterparty before onboarding.

This action is a thin, dependency-free wrapper (bash + curl + jq) around the Apify Actor
[neocraft/official-company-profile](https://apify.com/neocraft/official-company-profile). It starts a run in **your own Apify account**, waits for it, saves the results as JSON,
writes a readable job summary and exposes the key values as step outputs.

## Quick start

1. Create a free Apify account at <https://apify.com> and copy your API token (**Console → Settings → API & Integrations**).
2. In your GitHub repository: **Settings → Secrets and variables → Actions → New repository secret**, name `APIFY_TOKEN`.
3. Add a step to a workflow:

```yaml
    steps:
      - uses: Neocraft-tools/company-profile-action@v1
        with:
          apify-token: ${{ secrets.APIFY_TOKEN }}
          queries: |
            doctolib.fr
            794598813
            ticker:AAPL
```

A complete workflow is in [`examples/enrich-companies.yml`](examples/enrich-companies.yml).

## Pricing (pay per event, billed by Apify to your account)

**$0.003 per company found from an ID**, **$0.006 per company found from a domain or name** (website lookup), **+$0.002 per company** for the optional hiring-signals add-on, plus **$0.001 per run start**. Not found, ambiguous and invalid queries are free.

Prices are those of the [Apify Store page](https://apify.com/neocraft/official-company-profile) when this README was written; the Store page is the reference.
Platform usage is included in these prices. Apify's free plan includes a monthly credit that covers light use.
Every run is started with a hard spend cap (`max-total-charge-usd`): the Actor stops charging when the cap is reached.
This GitHub Action itself is free and open source; nothing is billed by Neocraft outside Apify.

## Inputs

| Name | Required | Default | Description |
|---|---|---|---|
| `apify-token` | yes |  | Your Apify API token (store it as a secret). Runs are billed to this Apify account. |
| `queries` | yes |  | Companies to look up, separated by commas or new lines: domain (doctolib.fr), name, SIREN, UK company number, LEI or ticker:AAPL. |
| `default-country` | no | `ANY` | Country used to interpret ambiguous queries: ANY, FR, GB or US. |
| `website-lookup` | no | `true` | Resolve domains by reading the company website (legal notice) when needed. |
| `hiring-signals` | no | `false` | Add hiring signals (open jobs) to each profile (paid add-on). |
| `fail-on-not-found` | no | `false` | Fail the step when a query does not resolve to exactly one company. |
| `extra-input` | no |  | Optional JSON object merged into the Actor input (any field of neocraft/official-company-profile). |
| `max-total-charge-usd` | no | `0.10` | Hard spend cap for the run in USD. |
| `timeout-secs` | no | `600` | Maximum run time of the Actor in seconds. |
| `output-file` | no | `company-profiles.json` | Where to save the full JSON results. |

## Outputs

| Name | Description |
|---|---|
| `found-count` | Number of queries resolved to a company. |
| `not-found-count` | Number of queries not found, ambiguous or invalid (free). |
| `profiles` | Compact JSON array (query, status, companyName, country, ids, legal status, incorporation date, address). |
| `results-file` | Path of the full JSON results. |
| `run-url` | Apify Console URL of the run. |

Every run also sets `run-id`, `run-status` and `item-count`.

## Notes

* Each query returns one item with `status`: `found` (the only charged status), `not_found`, `ambiguous` (with candidates), `excluded`, `invalid_input`, `error` or `skipped` (spend cap reached).
* Personal data (officers, beneficial owners) is deliberately not returned.
* Prefix tickers with `ticker:` and give a country with `default-country` when names are ambiguous.
* The step needs `curl` and `jq`, which are preinstalled on GitHub-hosted Ubuntu and macOS runners.
* Your token is only sent to `api.apify.com`. Keep it in a secret; never paste it in a workflow file.

## Related

* Apify Actor: [official-company-profile](https://apify.com/neocraft/official-company-profile) (also usable from the Apify Console, API, Python/Node clients, Make, Zapier, MCP/AI agents).
* More examples (Python, Node.js, curl, AI agents): [Neocraft-tools/apify-examples](https://github.com/Neocraft-tools/apify-examples).
* Other Neocraft actions: [website-audit-action](https://github.com/Neocraft-tools/website-audit-action), [page-change-monitor-action](https://github.com/Neocraft-tools/page-change-monitor-action), [website-screenshot-action](https://github.com/Neocraft-tools/website-screenshot-action), [hiring-tracker-action](https://github.com/Neocraft-tools/hiring-tracker-action).

## Self-test (maintainers)

[`examples/self-test.yml`](examples/self-test.yml) runs this action on cheap inputs (a few cents at most). To enable it,
copy it to `.github/workflows/self-test.yml`, add an `APIFY_TOKEN` secret, and start it from the **Actions** tab
(it only runs on `workflow_dispatch`).

## Support

Open an issue in this repository. Maintained by Xiaoli, an AI assistant, for Neocraft.

## License

[MIT](LICENSE)
