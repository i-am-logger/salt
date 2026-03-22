# Usage

## From any language

Each license is a standalone JSON file at `data/licenses/{key}.json`. No API needed — fetch or read the file directly.

### curl

```bash
# From GitHub raw
curl -s https://raw.githubusercontent.com/i-am-logger/salt/master/data/licenses/mit.json | jq

# Find all non-commercial licenses
for f in data/licenses/*.json; do
  if jq -e '.restrictions["commercial-use"]' "$f" > /dev/null 2>&1; then
    jq -r '.key' "$f"
  fi
done
```

### Python

```python
import json
from pathlib import Path

license = json.loads(Path("data/licenses/mit.json").read_text())
print(license["grants"])  # ['commercial-use', 'modifications', 'distribution', 'private-use']
```

### JavaScript

```javascript
const license = require('./data/licenses/mit.json');
console.log(license.restrictions);  // {}
```

## As a Nix flake

```nix
{
  inputs.salt.url = "github:i-am-logger/salt";

  outputs = { salt, ... }: {
    # Lookup by key (ScanCode LicenseDB identifier)
    mit = salt.licenses.mit;

    # Lookup by SPDX identifier (~786 licenses have SPDX IDs)
    apache = salt.spdx."Apache-2.0";

    # Metadata
    count = salt.meta.licenseCount;  # 2649
  };
}
```

### Querying

```nix
let
  salt = inputs.salt;

  # All licenses that restrict commercial use
  nonCommercial = lib.filterAttrs
    (_: l: l.restrictions.commercial-use or false)
    salt.licenses;

  # All copyleft licenses with SaaS disclosure
  saasDisclosure = lib.filterAttrs
    (_: l: builtins.elem "saas" (l.obligations.disclose-source or [])
        || builtins.elem "saas" (l.obligations.network-use-disclose or []))
    salt.licenses;

  # Check if a specific license allows commercial use
  canUseCommercially = license:
    builtins.elem "commercial-use" license.grants
    && !(license.restrictions.commercial-use or false);
in
  canUseCommercially salt.licenses.mit  # true
```

## Index file

`data/_index.json` provides a lightweight lookup without loading all 2649 files:

```json
{
  "licenses": [
    { "key": "mit", "category": "Permissive", "spdx": "MIT" },
    { "key": "gpl-3.0", "category": "Copyleft", "spdx": "GPL-3.0-only" },
    ...
  ],
  "meta": {
    "licenseCount": 2649,
    "allGrants": ["commercial-use", "modifications", "distribution", "patent-use", "private-use"],
    "allRestrictionKeys": ["commercial-use", "distribution", "modifications"],
    ...
  }
}
```
