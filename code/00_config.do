// =========================================================================
// 00_config.do — Portable path configuration for the replication package
//
// Run this BEFORE any other script. It sets global macros that the prep
// and analysis scripts reference, so the codebase no longer depends on
// one analyst's local file layout.
//
// Globals defined:
//   $repo  - repository root (this folder's parent)
//   $od    - same as $repo 
//   $ip    - input data path (raw data extracts)
//   $dp    - data path (cleaned intermediates)
//   $op    - output path (results, tables, figures)
//
// USAGE
//   1. Edit the `repo` macro below to point to your local clone of the
//      replication repository.
//   2. Either copy raw data into `data/raw/` or set `ip` to point at the
//      OneDrive location where the raw `.dta` files live.
//   3. Run this file at the top of every session:
//          do "code/00_config.do"
// =========================================================================

// --- Edit this single line for your machine ---
global repo = ""

// --- Derived paths (do not edit unless you reorganized the repo) ---
global od = "$repo"
global ip = "$repo/data/raw"
global dp = "$repo/data/clean"
global op = "$repo/output"

// Sanity check
capture confirm file "$repo/README.md"
if _rc {
    di as error "ERROR: \$repo macro does not point at a valid repository clone."
    di as error "       Edit code/00_config.do and re-run."
    exit 198
}

di "Config loaded. \$repo = $repo"
