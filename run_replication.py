#!/usr/bin/env python3
"""Single entrypoint for the ILR paper replication workflow.

Run from the package root:
    python run_replication.py                               # full replication
    python run_replication.py --check                       # validate setup, run nothing
    python run_replication.py --from data_prepare_latin.do  # resume from a stage

Stata and R are located automatically (PATH first, then the standard
Windows install folders). Use --stata / --rscript to override.
"""
from __future__ import annotations
import argparse
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
BLD = ROOT / "bld"
RAW = ROOT / "data" / "raw"
LOG = BLD / "replication.log"
ANCILLARY_FILES = [
    "soc10_isco08.dta",
    "soc18_soc10_diff.dta",
    "population_totals/1710000901-noSymbol.csv",
    "population_totals/Poblacion_01.xlsx",
    "population_totals/popest-annual.xls",
    "population_totals/serie_2001_2015_TCU.xls",
    "population_totals/P_Data_Extract_From_World_Development_Indicators/69e1ed3e-833e-444c-b892-93ce505de507_Data.csv",
]
RESTRICTED_DIRS = ["eu_lfs", "zaf_ghs", "ARG", "BRA", "COL", "MEX", "URY", "USA"]
PYTHON_PACKAGES = ["pandas", "xlrd", "openpyxl"]
STAGES = [
    ("EU occupational unemployment rates", "stata", "unempl_rates_eu_lfs.do"),
    ("World marriage-population series", "python", "graph_same_sex_marriage_legislation.py"),
    ("European and South African preparation", "r", "data_preparation_eu_rpa.R"),
    ("Latin American preparation", "stata", "data_prepare_latin.do"),
    ("United States preparation", "stata", "data_prepare_usa.do"),
    ("Append analysis datasets", "stata", "appending_main_dataset.do"),
    ("Descriptive-check figures", "stata", "figures_desc_check.do"),
    ("Descriptive tables and figures", "stata", "descriptives.do"),
    ("Descriptive-statistics inputs", "stata", "desc_stats.do"),
    ("Descriptive-statistics TeX fragments", "python", "descriptive_tables.py"),
    ("Main regressions", "stata", "regressions.do"),
    ("Rural-sample robustness", "stata", "regressions_inclrural.do"),
    ("Occupational-risk analysis", "stata", "unemp_risk_analysis.do"),
    ("Occupational-risk figures", "stata", "graphs_regressions.do"),
    ("Other robustness regressions", "stata", "regressions_robustness.do"),
    ("Marginal-prediction figures", "stata", "margins.do"),
    ("Population figure", "stata", "miscellaneous.do"),
]

# Stata error codes appear in the log on their own line, e.g. "r(199);"
STATA_ERROR = re.compile(r"^r\(\d+\);", re.MULTILINE)
UTF8_BOM = b"\xef\xbb\xbf"
DEFAULT_STATA = "stata-mp"
DEFAULT_RSCRIPT = "Rscript"


# ---------------------------------------------------------------- software

def _version_key(path: Path) -> int:
    """Largest number in the install folder name, e.g. StataNow19 -> 19, R-4.5.1 -> 451."""
    for folder in path.parents:
        if re.match(r"^(R-|Stata)", folder.name):
            digits = re.findall(r"\d+", folder.name)
            return int("".join(digits)) if digits else 0
    return 0


def find_stata(requested: str) -> str | None:
    found = shutil.which(requested)
    if found or requested != DEFAULT_STATA:
        return found
    for name in ("stata-mp", "stata-se", "stata"):  # Linux/macOS names
        if shutil.which(name):
            return shutil.which(name)
    # Windows: C:\Program Files\Stata*\Stata{MP,SE,BE,IC}-64.exe
    editions = ["StataMP-64.exe", "StataSE-64.exe", "StataBE-64.exe", "StataIC-64.exe"]
    candidates = []
    for base in {os.environ.get("ProgramFiles", r"C:\Program Files"), r"C:\Program Files"}:
        for folder in Path(base).glob("Stata*"):
            for rank, exe in enumerate(editions):
                if (folder / exe).is_file():
                    candidates.append((rank, -_version_key(folder / exe), folder / exe))
    return str(min(candidates)[2]) if candidates else None


def find_rscript(requested: str) -> str | None:
    found = shutil.which(requested)
    if found or requested != DEFAULT_RSCRIPT:
        return found
    # Windows: C:\Program Files\R\R-x.y.z\bin\x64\Rscript.exe
    candidates = []
    for base in {os.environ.get("ProgramFiles", r"C:\Program Files"), r"C:\Program Files"}:
        candidates += [p for p in Path(base).glob("R/R-*/bin/x64/Rscript.exe") if p.is_file()]
        candidates += [p for p in Path(base).glob("R/R-*/bin/Rscript.exe") if p.is_file()]
    if not candidates:
        return None
    return str(max(candidates, key=lambda p: (_version_key(p), "x64" in p.parts)))


def missing_python_packages() -> list[str]:
    import importlib.util
    return [pkg for pkg in PYTHON_PACKAGES if importlib.util.find_spec(pkg) is None]


# ---------------------------------------------------------------- source files

def files_with_bom() -> list[Path]:
    """Stata (and Rscript on Windows) choke on a UTF-8 byte-order mark."""
    scripts = list((ROOT / "code" / "stata").glob("*.do")) + list((ROOT / "code" / "R").glob("*.R"))
    return [p for p in scripts if p.read_bytes().startswith(UTF8_BOM)]


def strip_bom(paths: list[Path]) -> None:
    for path in paths:
        path.write_bytes(path.read_bytes()[len(UTF8_BOM):])


# ---------------------------------------------------------------- pipeline

def make_directories() -> None:
    relative = [
        "data", "data/data_countries", "data/counts/Europe", "data/counts/USA",
        "data/counts/BRA", "data/descriptives", "data/descriptives/hh_head",
        "data/descriptives/hh_head_all_couples", "data/descriptives/under_15",
        "data/descriptives/poly", "data/regressions", "data/margins",
        "data/unempl_rates_eu_lfs",
        "data/Europe", "data/ZAF", "data/ARG", "data/BRA", "data/COL", "data/URY",
        "data/USA", "tables", "figures",
    ]
    for item in relative:
        (BLD / item).mkdir(parents=True, exist_ok=True)


def command(kind: str, script: str, stata: str, rscript: str) -> tuple[list[str], Path]:
    if kind == "stata":
        return [stata, "-b", "do", script], ROOT / "code" / "stata"
    if kind == "r":
        return [rscript, script], ROOT / "code" / "R"
    return [sys.executable, script], ROOT / "code" / "python"


def stata_log_path(cmd: list[str], cwd: Path) -> Path:
    """Batch-mode Stata writes <dofile>.log into the working directory."""
    return cwd / Path(cmd[-1]).with_suffix(".log").name


def stata_failed(log_path: Path) -> str | None:
    """Return a reason if the Stata log is missing or contains an error code."""
    if not log_path.exists():
        return "no Stata log was written"
    text = log_path.read_text(encoding="utf-8", errors="replace")
    match = STATA_ERROR.search(text)
    if match:
        return f"Stata error {match.group(0).rstrip(';')}"
    return None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stata", default=DEFAULT_STATA, help="Stata executable (auto-detected if omitted)")
    parser.add_argument("--rscript", default=DEFAULT_RSCRIPT, help="Rscript executable (auto-detected if omitted)")
    parser.add_argument("--check", action="store_true", help="validate and print commands only")
    parser.add_argument("--from", dest="start", metavar="STAGE",
                        help="resume from this stage: its script name (e.g. data_prepare_latin.do) "
                             "or its number as listed by --check; earlier stages are skipped")
    args = parser.parse_args()

    start_index = 0
    if args.start:
        scripts = [script for _label, _kind, script in STAGES]
        if args.start.isdigit() and 1 <= int(args.start) <= len(STAGES):
            start_index = int(args.start) - 1
        elif args.start in scripts:
            start_index = scripts.index(args.start)
        else:
            print(f"Unknown stage '{args.start}'. Use a script name or a number from 1 to {len(STAGES)}; "
                  "run with --check to see the list.", file=sys.stderr)
            return 2

    stata = find_stata(args.stata)
    rscript = find_rscript(args.rscript)
    missing_ancillary = [item for item in ANCILLARY_FILES if not (RAW / item).is_file()]
    missing_restricted = [item for item in RESTRICTED_DIRS if not (RAW / item).is_dir()]
    missing_packages = missing_python_packages()
    bom_files = files_with_bom()
    commands = [(label, kind, *command(kind, script, stata or args.stata, rscript or args.rscript))
                for label, kind, script in STAGES]

    if args.check:
        print(f"Included ancillary files: {len(ANCILLARY_FILES) - len(missing_ancillary)}/{len(ANCILLARY_FILES)}")
        print("Restricted survey directories missing: " + (", ".join(missing_restricted) or "none"))
        print(f"Software Stata: {stata or 'MISSING'}")
        print(f"Software Rscript: {rscript or 'MISSING'}")
        print("Python packages missing: " + (", ".join(missing_packages) or "none"))
        print("Scripts with a UTF-8 BOM (fixed automatically on a full run): "
              + (", ".join(p.name for p in bom_files) or "none"))
        for number, (label, _kind, cmd, cwd) in enumerate(commands, start=1):
            marker = "skip" if number - 1 < start_index else "run "
            print(f"{number:2d} [{marker}] {label}: cwd={cwd.relative_to(ROOT)} command={' '.join(cmd)}")
        return 0

    if missing_ancillary or missing_restricted:
        if missing_ancillary:
            print("Missing ancillary files: " + ", ".join(missing_ancillary), file=sys.stderr)
        if missing_restricted:
            print("Missing restricted survey directories: " + ", ".join(missing_restricted), file=sys.stderr)
        print("See README.md for the required directory layout.", file=sys.stderr)
        return 2
    missing_software = [name for name, path in (("Stata", stata), ("Rscript", rscript)) if path is None]
    if missing_software:
        print("Could not find: " + ", ".join(missing_software)
              + ". Pass the full path with --stata and/or --rscript.", file=sys.stderr)
        return 2
    if missing_packages:
        print("Missing Python packages: " + ", ".join(missing_packages)
              + f". Install with: {Path(sys.executable).name} -m pip install "
              + " ".join(missing_packages), file=sys.stderr)
        return 2

    strip_bom(bom_files)
    make_directories()
    # A resumed run appends to the existing log so the earlier stages' record is kept.
    with LOG.open("a" if start_index else "w", encoding="utf-8") as log:
        log.write(f"Started {datetime.now(timezone.utc).isoformat()}\n")
        if start_index:
            log.write(f"Resuming from stage {start_index + 1}: {STAGES[start_index][0]}\n")
        log.write(f"Stata: {stata}\nRscript: {rscript}\nPython: {sys.executable}\n")
        if bom_files:
            log.write("Removed UTF-8 BOM from: " + ", ".join(p.name for p in bom_files) + "\n")
        for label, kind, cmd, cwd in commands[start_index:]:
            line = f"RUN {label}: {' '.join(cmd)} (cwd={cwd.relative_to(ROOT)})"
            print(line)
            log.write(line + "\n")
            log.flush()
            if kind == "stata":
                # Remove any log from a previous run so a stale file can't pass the check.
                stata_log_path(cmd, cwd).unlink(missing_ok=True)
            result = subprocess.run(cmd, cwd=cwd, stdout=log, stderr=subprocess.STDOUT)
            if result.returncode:
                print(f"FAILED: {label}; see {LOG}", file=sys.stderr)
                return result.returncode
            if kind == "stata":
                # Windows batch-mode Stata exits with 0 even after an error,
                # so inspect its log instead of trusting the return code.
                stata_log = stata_log_path(cmd, cwd)
                reason = stata_failed(stata_log)
                if reason:
                    log.write(f"FAILED {label}: {reason}\n")
                    print(f"FAILED: {label}; {reason}, see {stata_log}", file=sys.stderr)
                    return 1
            log.write(f"OK {label}\n")
    print(f"Completed. Outputs are under {BLD}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
