# SALT taxonomy tests

{ licenses, spdx, meta, ... }:

let

  assertTrue = name: value:
    if value then true
    else throw "FAIL: ${name}";

  assertEq = name: actual: expected:
    if actual == expected then true
    else throw "FAIL: ${name}: expected ${builtins.toJSON expected}, got ${builtins.toJSON actual}";

  has = builtins.hasAttr;
  l = key: licenses.${key};

in
{
  # ── Coverage ────────────────────────────────────────────────────

  hasLicenses = assertTrue "2600+ licenses"
    (meta.licenseCount >= 2600);

  # ── Well-known licenses ─────────────────────────────────────────

  hasMit = assertTrue "MIT exists" (has "mit" licenses);
  hasApache = assertTrue "Apache 2.0 exists" (has "apache-2.0" licenses);
  hasGpl2 = assertTrue "GPL 2.0 exists" (has "gpl-2.0" licenses);
  hasGpl3 = assertTrue "GPL 3.0 exists" (has "gpl-3.0" licenses);
  hasAgpl3 = assertTrue "AGPL 3.0 exists" (has "agpl-3.0" licenses);
  hasLgpl21 = assertTrue "LGPL 2.1 exists" (has "lgpl-2.1" licenses);
  hasMpl2 = assertTrue "MPL 2.0 exists" (has "mpl-2.0" licenses);
  hasCc0 = assertTrue "CC0 exists" (has "cc0-1.0" licenses);
  hasUnlicense = assertTrue "Unlicense exists" (has "unlicense" licenses);
  hasCcByNc40 = assertTrue "CC-BY-NC-4.0 exists" (has "cc-by-nc-4.0" licenses);
  hasCcByNd40 = assertTrue "CC-BY-ND-4.0 exists" (has "cc-by-nd-4.0" licenses);

  # ── SPDX lookup ────────────────────────────────────────────────

  spdxMit = assertTrue "MIT by SPDX" (has "MIT" spdx);
  spdxApache = assertTrue "Apache-2.0 by SPDX" (has "Apache-2.0" spdx);
  spdxCcByNc = assertTrue "CC-BY-NC-4.0 by SPDX" (has "CC-BY-NC-4.0" spdx);

  # ── Categories ──────────────────────────────────────────────────

  mitIsPermissive = assertEq "MIT is Permissive" (l "mit").category "Permissive";
  gpl3IsCopyleft = assertEq "GPL 3.0 is Copyleft" (l "gpl-3.0").category "Copyleft";
  ccByNcIsNc = assertEq "CC-BY-NC-4.0 is Non-Commercial" (l "cc-by-nc-4.0").category "Non-Commercial";

  # ── License terms ──────────────────────────────────────────────

  ncRestrictsCommercial = assertTrue "NC restricts commercial-use"
    ((l "cc-by-nc-4.0").restrictions.commercial-use or false);

  mitNoRestrictions = assertEq "MIT has no restrictions" (l "mit").restrictions { };

  mitGrantsCommercial = assertTrue "MIT grants commercial-use"
    (builtins.elem "commercial-use" (l "mit").grants);

  gpl3HasDiscloseSource = assertTrue "GPL 3.0 has disclose-source"
    (has "disclose-source" (l "gpl-3.0").obligations);

  gpl3HasSameLicense = assertTrue "GPL 3.0 has same-license"
    (has "same-license" (l "gpl-3.0").obligations);

  mitHasHomepage = assertTrue "MIT has homepage URL"
    ((l "mit").homepage_url != null);

  # ── Structure integrity ─────────────────────────────────────────

  allHaveCategory = assertTrue "all have category"
    (builtins.all (x: x ? category) (builtins.attrValues licenses));

  allHaveKey = assertTrue "all have key"
    (builtins.all (x: x ? key) (builtins.attrValues licenses));

  allHaveGrants = assertTrue "all have grants"
    (builtins.all (x: x ? grants) (builtins.attrValues licenses));

  allHaveObligations = assertTrue "all have obligations"
    (builtins.all (x: x ? obligations) (builtins.attrValues licenses));

  allHaveRestrictions = assertTrue "all have restrictions"
    (builtins.all (x: x ? restrictions) (builtins.attrValues licenses));

  allHaveDisclaimers = assertTrue "all have disclaimers"
    (builtins.all (x: x ? disclaimers) (builtins.attrValues licenses));

  # ── Integrity ───────────────────────────────────────────────────

  allHaveIntegrity = assertTrue "all have integrity"
    (builtins.all (x: x ? integrity) (builtins.attrValues licenses));

  allHaveDigest = assertTrue "all have integrity.digest"
    (builtins.all (x: x.integrity ? digest) (builtins.attrValues licenses));

  allHaveAlgorithm = assertTrue "all have integrity.algorithm"
    (builtins.all (x: x.integrity ? algorithm) (builtins.attrValues licenses));

  allUseSha256 = assertTrue "all use sha256"
    (builtins.all (x: x.integrity.algorithm == "sha256") (builtins.attrValues licenses));
}
