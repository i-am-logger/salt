[![Nix](https://img.shields.io/badge/Nix-flake-5277C3?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![CI](https://github.com/i-am-logger/salt/actions/workflows/ci-and-release.yml/badge.svg)](https://github.com/i-am-logger/salt/actions/workflows/ci-and-release.yml)

[![Release](https://img.shields.io/github/v/release/i-am-logger/salt?include_prereleases)](https://github.com/i-am-logger/salt/releases)
[![Licenses](https://img.shields.io/badge/Licenses-2649-blue)](https://github.com/i-am-logger/salt)

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

# SALT

**S**oftware **A**nd **L**icense **T**axonomy

When you use a piece of software, its license determines what you can and cannot do with it. Can you use it commercially? Must you share your source code? Can you redistribute it? Can you modify it?

SALT answers these questions for 2649 software licenses. Each license is classified into four areas (see [TERMS.md](TERMS.md) for all values):

- **[Grants](TERMS.md#grants)** — what the license lets you do (use commercially, modify, distribute, use patents, use privately)
- **[Obligations](TERMS.md#obligations)** — what you must do in return (include the copyright notice, disclose your source code, use the same license, document your changes)
- **[Restrictions](TERMS.md#restrictions)** — what the license forbids (commercial use, redistribution, modification)
- **[Disclaimers](TERMS.md#disclaimers)** — what the license does not guarantee (no liability, no warranty, no patent rights, no trademark rights)

Every license is a single JSON file with a link to the original license text and a SHA-256 integrity hash.

## Example

[`data/licenses/mit.json`](data/licenses/mit.json):

```json
{
  "key":              "mit",
  "name":             "MIT License",
  "short_name":       "MIT License",
  "spdx_license_key": "MIT",
  "category":         "Permissive",

  "homepage_url": "http://opensource.org/licenses/mit-license.php",
  "text_urls":    ["http://opensource.org/licenses/mit-license.php"],

  "grants":       ["commercial-use", "modifications", "distribution", "private-use"],
  "obligations":  { "include-copyright": ["distribution"] },
  "restrictions": {},
  "disclaimers":  ["liability", "warranty"],

  "integrity": {
    "algorithm": "sha256",
    "digest":    "946b1bf9..."
  }
}
```

This tells you: MIT lets you do anything (commercial use, modify, distribute, private use). Your only obligation is to include the copyright notice when you distribute. There are no restrictions. The author disclaims liability and warranty. The integrity hash lets you verify the data hasn't been modified.

Compare with [`data/licenses/cc-by-nc-4.0.json`](data/licenses/cc-by-nc-4.0.json) — notice `commercial-use` is missing from grants and present in restrictions. A company using this software commercially would be in violation:

```json
{
  "key":      "cc-by-nc-4.0",
  "category": "Non-Commercial",

  "grants":       ["modifications", "distribution", "private-use"],
  "restrictions": { "commercial-use": true }
}
```

## Structure

```
data/
├── _index.json           # All 2649 keys, categories, and SPDX IDs
└── licenses/
    ├── mit.json
    ├── gpl-3.0.json
    ├── cc-by-nc-4.0.json
    └── ... (2649 files)
```

Each file is the system of record for that license. Edit it directly to correct or update a classification.

## Documentation

| Document | Contents |
|----------|----------|
| [TERMS.md](TERMS.md) | Definitions of all grants, obligations, restrictions, disclaimers, and categories |
| [USAGE.md](USAGE.md) | How to query and integrate SALT (Nix, curl, Python, JavaScript) |
| [ATTRIBUTION.md](ATTRIBUTION.md) | Upstream data source credits |

## Disclaimer

SALT is a classification tool, not legal advice. Classifications represent a reasonable interpretation of each license's terms but may not reflect all nuances, jurisdictional variations, or recent amendments. Consult a qualified attorney for legal decisions.

## Attribution

License data was initially derived from [ScanCode LicenseDB](https://github.com/aboutcode-org/scancode-licensedb) and [choosealicense.com](https://github.com/github/choosealicense.com), then manually classified. See [ATTRIBUTION.md](ATTRIBUTION.md).

## Contributing

Edit the JSON file directly in `data/licenses/`. Each file is the system of record for that license.

## Development

```bash
nix develop       # Dev shell with pre-commit hooks
nix flake check   # Run all checks
nix fmt           # Format all files
```
