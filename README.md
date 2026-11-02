# demo3

Static page served at **https://talos-hq.github.io/demo3/** (GitHub Pages, `main` branch, root).
The talos-hq org has a custom Pages domain, so that URL 301-redirects to **http://talosbot.ai/demo3/**;
`publish.sh --verify` follows the redirect.

## Source / provenance
- Original: https://gist.githubusercontent.com/Alana11nextus/8aa64596e531c729aa09c722fa3911f1/raw/zachvorhies-home-DEPLOY-index.html
- Fetched: 2026-11-01
- Unmodified copy: [`source/zachvorhies-home-DEPLOY-index.html`](source/zachvorhies-home-DEPLOY-index.html); `index.html` is byte-identical.

## Updating
```sh
./publish.sh            # re-fetch, secret-scan (aborts on any hit), write index.html + source/
git commit -am "update from gist" && git push
./publish.sh --verify   # bounded poll: live URL returns 200 and contains the page title
```

## Secret scan (2026-11-01)
Clean: no tokens, API keys, private keys, internal hostnames or private IPs. The only email is
`zach@zachvorhies.com`, the public contact address the page itself displays (allow-listed).

## Known breakage under /demo3/
All images use absolute `https://www.zachvorhies.com/...` URLs and returned 200 when checked.
The page was written for a domain root, so these root-relative links 404 here (not rewritten, by
design — content is published as-is): `/`, `/ai`, `/ai#reviews`, `/blacklists/index.html`,
`/blacklists/youtube_blacklist.txt`, `/covfefe`, `/google_cloud_diversity/`,
`/google_definition_of_algorithmic_unfairness`, `/google_diversity_summit/`,
`/google_efforts_to_address_fake_news/index.html`, `/google_fake_news_letter/index.html`,
`/google_leaks/`, `/google_realtime_events`, `/google_resist.html`,
`/google_seeds_of_change/index.html`, `/imgs/favicon.png` (favicon missing), `/msm_rankings.html`,
`/people_programmed.html`, `/realtime_boost`.
