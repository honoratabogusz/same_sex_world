# Replication package

## Scope

This package contains the minimum retained code path for tables and figures in Bogusz, H., & Gromadzki, J. (2026), Labor Market Outcomes of Same-Sex Couples in Countries with Legalized Same-Sex Marriage. *ILR Review*. https://doi.org/10.1177/00197939261485216

## Layout

- `run_replication.py`: the master script used to run the entire replication.
- `code/stata/`: retained Stata preparation, estimation, table, and figure code.
- `code/R/`: EU LFS and South Africa preparation.
- `code/python/`: population-series and descriptive-table construction.
- `data/raw/`: included ancillary population and occupation-crosswalk inputs, plus locations for restricted survey data.
- `VARIABLE_DICTIONARY.xlsx`: retained-variable definitions.

## Raw data access

Except for the EU-LFS, the raw data can be obtained from the respective data providers. The instructions below describe the releases and variables expected by the replication code.

### Countries in the final analysis sample

#### Brazil &mdash; Pesquisa Nacional por Amostra de Domic&iacute;lios Cont&iacute;nua (PNAD Cont&iacute;nua)

- **Provider:** [Brazilian Institute of Geography and Statistics (IBGE)](https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Trimestral/Microdados/)
- **Files:** Download the quarterly microdata for 2015&ndash;2019.
- **Conversion:** Install the `datazoom_social` Stata package:

  ```stata
  net install datazoom_social, from("https://raw.githubusercontent.com/datazoompuc/datazoom_social_stata/main/") force
  ```

  Use the package to convert the downloaded files to Stata `.dta` format.

#### European Union and United Kingdom &mdash; European Labour Force Survey (EU-LFS)

- **Provider:** [Eurostat microdata access](https://ec.europa.eu/eurostat/web/microdata/overview)
- **Access:** The EU-LFS microdata are confidential and cannot be redistributed with this package. Eurostat grants access to the scientific use files for scientific purposes only, and only to researchers at an organisation that Eurostat has recognised as a research entity (for example a university or research institute). Access is a two-step procedure:
  1. **Research-entity recognition.** Check whether your organisation is already on Eurostat's [list of recognised research entities](https://ec.europa.eu/eurostat/web/microdata/research-entities). If it is not, the organisation applies once for recognition; Eurostat indicates this takes around 4 weeks. The application form and instructions are in Eurostat's guide [How to apply for microdata access](https://ec.europa.eu/eurostat/documents/203647/771732/How_to_apply_for_microdata_access.pdf).
  2. **Research proposal.** Submit a research proposal requesting the EU-LFS through Eurostat's [Microdata Access Portal](https://ec.europa.eu/eurostat/web/microdata/access). You need your organisation's research-entity number, the name of its contact person, and an EU Login account with two-factor authentication linked to a professional e-mail address. Eurostat indicates the assessment takes around 10 weeks, and access is valid for the period stated in the proposal.
- **Contact:** For questions about eligibility, the application or the data, contact the Eurostat microdata team at [estat-microdata-access@ec.europa.eu](mailto:estat-microdata-access@ec.europa.eu).
- **Files:** Request the annual EU-LFS scientific use files covering 2015&ndash;2019.

#### United States &mdash; American Community Survey (ACS)

- **Provider:** [IPUMS USA](https://usa.ipums.org/usa-action/samples)
- **Sample:** Log in and select the 2019 ACS five-year sample.
- **Variables:** `multyear`, `year`, `serial`, `perwt`, `density`, `age`, `sex`, `related`, `sploc`, `marst`, `ssmc`, `statefip`, `bpl`, `educ`, `citizen`, `race`, `empstat`, `uhrswork`, `wkswork2`, `incwage`, `incbus00`, `classwkr`, and `occsoc`.

#### Uruguay &mdash; Encuesta Continua de Hogares (ECH)

- **Provider:** [Instituto Nacional de Estad&iacute;stica](https://www4.ine.gub.uy/Anda5/index.php/catalog/Encuestas_a_hogares)
- **Files:** Download the annual household-survey files for 2015&ndash;2019 in SPSS `.sav` format.

### Countries used in data-quality checks

#### Argentina &mdash; Encuesta Permanente de Hogares (EPH)

- **Provider:** [INDEC microdata catalogue](https://www.indec.gob.ar/indec/web/Institucional-Indec-BasesDeDatos)
- **Files:** Under "Microdatos y documentos 2016&ndash;2026," download every quarterly file for 2016&ndash;2019. Under "Microdatos y documentos 2003&ndash;2015," download the two available quarters for 2015.

#### Colombia &mdash; Gran Encuesta Integrada de Hogares (GEIH)

- **Provider:** [DANE Microdata Archive](https://microdatos.dane.gov.co/index.php/catalog/900/related-materials)
- **Files:** Download the monthly 2015&ndash;2019 files named `Area - Caracteristicas generales (Personas).dta`, `Cabecera - Caracteristicas generales (Personas).dta`, and `Resto - Caracter&iacute;sticas generales (Personas).dta`.
- **Access note:** As of 2026, access from Austria and Poland may be unavailable.

#### Mexico &mdash; Encuesta Nacional de Ocupaci&oacute;n y Empleo (ENOE)

- **Provider:** [IPUMS International](https://international.ipums.org/international-action/samples)
- **Samples:** Log in, open the "Surveys" tab, and select the quarterly 2015&ndash;2019 files.
- **Variables:** `geo1_mx`, `serial`, `sample`, `year`, `perwt`, `urban`, `age`, `sex`, `related`, `edattain`, and `empstat`.

#### South Africa &mdash; General Household Survey (GHS)

- **Provider:** Statistics South Africa (Stats SA); distributed by [DataFirst, University of Cape Town](https://www.datafirst.uct.ac.za/dataportal/index.php/catalog/central).
- **Access:** Public-use data, free of charge after registering an account with DataFirst.
- **Files:** Search the DataFirst catalogue for "General Household Survey" and download the **person** file for each year 2015&ndash;2019 (for example, [GHS 2019](https://www.datafirst.uct.ac.za/dataportal/index.php/catalog/852) and [GHS 2018](https://www.datafirst.uct.ac.za/dataportal/index.php/catalog/801)) in CSV format.
- **Note:** The GHS questionnaire changed in 2019 and variables were renamed; DataFirst provides a correspondence document (`ghs-2019-variables-renamed`) with the 2019 study.

## Data placement

Obtain the authors' exact 2015--2019 survey extracts and preserve their original filenames. Place them below `data/raw/` using these source-code directories:

- `eu_lfs/`: annual EU LFS CSV files and occupational-unemployment extracts.
- `zaf_ghs/`: South African GHS person CSV files.
- `ARG/`, `BRA/`, `COL/`, `MEX/`, `URY/`, and `USA/`: country survey extracts.

## Software

Required: Python 3.9+, R 4.x, and Stata with `gtools`, `estout`, `texsave`, `grc1leg`, and the `plotplainblind` scheme. Python requires `pandas` and `openpyxl`. R requires `dplyr`, `haven`, `stringr`, `countrycode`, and `purrr`.

## Run

From the package root:

```text
python run_replication.py --check
python run_replication.py
```

If Stata is named differently:

```text
python run_replication.py --stata /path/to/stata
```

The runner uses only package-relative paths, stops at the first failed stage, and writes generated datasets to `bld/data/`, TeX fragments to `bld/tables/`, figures to `bld/figures/`, and the execution log to `bld/replication.log`.

## Exhibit dictionary

Exhibits are listed in manuscript order. `{country}` denotes BEL, BRA, FRA, DEU, NLD, GBR, USA, or URY; `{region}` denotes the three manuscript panels.

| Manuscript exhibit | Title | Generated artifact(s) | Final generating script |
| --- | --- | --- | --- |
| Figure 1 | Population of countries with access to same-sex marriage | `bld/figures/population_samesex_marriage_world_our_data.png` | `code/stata/miscellaneous.do` |
| Table 1 | Institutional and cultural characteristics | Inline manuscript TeX | None |
| Table 2 | Survey-data description | Inline manuscript TeX | None |
| Table 3 | Descriptive statistics | `bld/tables/desc_stats_{hh,individual_men,individual_women,individual_nobs}_cntry{1,2}.tex` | `code/python/descriptive_tables.py` |
| Figure 2 | Labor-force participation, both partners active | `bld/figures/margins_ls_{country}.pdf` | `code/stata/margins.do` |
| Figure 3 | Total hours worked | `bld/figures/margins_hw_{country}.pdf` | `code/stata/margins.do` |
| Figure 4 | Hours worked by the secondary worker | `bld/figures/margins_hw_secondary_{country}.pdf` | `code/stata/margins.do` |
| Figure 5 | Unemployment: men | `bld/figures/margins_unemp_s1_{country}.pdf` | `code/stata/margins.do` |
| Figure 6 | Unemployment: women | `bld/figures/margins_unemp_s2_{country}.pdf` | `code/stata/margins.do` |
| Figure 7 | Unemployment accounting for occupational segregation | `bld/figures/bar_unemp_rate_occ_country_{country}.png` | `code/stata/graphs_regressions.do` |
| Table 4 | Selection into parenthood | `bld/tables/table_children_all_{region}.tex` | `code/stata/descriptives.do` |
| Figure A.1 | Urban population share by couple type | `bld/figures/urban_all_countries_sample.png` | `code/stata/figures_desc_check.do` |
| Table A.1 | Literature on labor supply and unemployment among same-sex couples | Inline manuscript TeX | None |
| Table A.2 | Baseline regression results, full controls | `bld/tables/baseline_reg_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table A.3 | Secondary worker share of household hours | `bld/tables/table_hw_share_countries.tex` | `code/stata/regressions.do` |
| Table A.4 | Individual labor-force participation, men | `bld/tables/table_lf_ind_men_countries.tex` | `code/stata/regressions.do` |
| Table A.5 | Individual labor-force participation, women | `bld/tables/table_lf_ind_women_countries.tex` | `code/stata/regressions.do` |
| Table A.6 | Individual hours worked, men | `bld/tables/table_hw_ind_men_countries.tex` | `code/stata/regressions.do` |
| Table A.7 | Individual hours worked, women | `bld/tables/table_hw_ind_women_countries.tex` | `code/stata/regressions.do` |
| Table A.8 | Gender gaps in labor supply | `bld/tables/ggaps_countries_{1,2}.tex` | `code/stata/regressions.do` |
| Table A.9 | Self-employment, men | `bld/tables/table_selfemp_men_countries.tex` | `code/stata/regressions.do` |
| Table A.10 | Self-employment, women | `bld/tables/table_selfemp_women_countries.tex` | `code/stata/regressions.do` |
| Table A.11 | Relationship of people under 15 to household head | `bld/tables/table_under_15_couple_type.tex` | `code/stata/descriptives.do` |
| Table A.12 | Own children versus relatives children | `bld/tables/table_nonchildren_all_{region}.tex` | `code/stata/descriptives.do` |
| Table B.1 | Robustness for ages 25-39 | `bld/tables/rob_age2539_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table B.2 | At least one partner with tertiary education | `bld/tables/rob_edut_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table B.3 | Neither partner with tertiary education | `bld/tables/rob_edunt_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table B.4 | Robustness for married couples | `bld/tables/rob_mar_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table B.5 | Robustness including rural areas | `bld/tables/rob_rural_countries{1,2}.tex` | `code/stata/regressions_inclrural.do` |
| Table B.6 | Region-specific year fixed effects | `bld/tables/rob_cyrfx_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table B.7 | Controlling for immigrant status | `bld/tables/rob_cimg_countries{1,2}.tex` | `code/stata/regressions_robustness.do` |
| Table B.8 | Controlling for race | `bld/tables/rob_crace_countries1.tex` | `code/stata/regressions_robustness.do` |
| Table C.1 | Selection into marriage | `bld/tables/table_marriage_{region}.tex` | `code/stata/descriptives.do` |
| Table C.2 | Selection into parenthood excluding Brazil | `bld/tables/table_children_all_bra_{region}.tex` | `code/stata/descriptives.do` |
| Table C.3 | Selection into parenthood among married couples | `bld/tables/table_children_married_{region}.tex` | `code/stata/descriptives.do` |
| Table C.4 | Selection into parenthood among unmarried couples | `bld/tables/table_children_unmarried_{region}.tex` | `code/stata/descriptives.do` |
| Table D.1 | Variable descriptions | Inline manuscript TeX | None |
| Table D.2 | Survey coverage and same-sex-marriage legalization | Inline manuscript TeX | None |
| Figure D.1 | Same-sex-couple respondent counts in Europe | `bld/figures/ssc_ind_counts_eu_lfs.png` | `code/stata/descriptives.do` |
| Figure D.2 | Same-sex-couple respondent shares by marriage-law status | `bld/figures/ssc_ind_shares_eu_lfs.png` | `code/stata/descriptives.do` |
| Figure D.3 | Household-head couples as a share of all couples | `bld/figures/hh_head_all_couples.png` | `code/stata/descriptives.do` |
| Figure D.4 | Countries legalizing same-sex marriage by 2017 | `figures/map.pdf` | None |
| Table D.3 | Summary of data-quality checks | Inline manuscript TeX | None |
| Table D.4 | Survey respondents in same-sex couples by country | `bld/tables/table_counts.tex` | `code/stata/descriptives.do` |
| Table D.5 | Maximum year-to-year demographic change | `bld/tables/table_desc_quality_check.tex` | `code/stata/descriptives.do` |
| Table D.6 | Same-sex-couple share by country and age | `bld/tables/table_counts_shares.tex` | `code/stata/descriptives.do` |
| Figure D.5 | Average age by couple type, country, and year | `bld/figures/age_all.pdf` | `code/stata/figures_desc_check.do` |
| Figure D.6 | Secondary education by couple type, country, and year | `bld/figures/edu_secondary_all.pdf` | `code/stata/figures_desc_check.do` |
| Figure D.7 | Tertiary education by couple type, country, and year | `bld/figures/edu_tertiary_all.pdf` | `code/stata/figures_desc_check.do` |
| Figure D.8 | Same-sex-couple share by age group | `bld/figures/bar_couples_share_prime_age_old_age.png` | `code/stata/descriptives.do` |
| Figure D.9 | Same-sex-couple share by country and year | `bld/figures/SSC_ratio_all.pdf` | `code/stata/figures_desc_check.do` |
| Figure D.10 | Actual and predicted occupational unemployment risk | `bld/figures/scatter_unemp_occ_risk_{country}.png` | `code/stata/unemp_risk_analysis.do` |
| Table D.7 | Occupational segregation by relationship type | `bld/tables/table_occ_segregation_duncan.tex` | `code/stata/unemp_risk_analysis.do` |
| Table D.8 | Occupational segregation by gender and couple type | `bld/tables/table_occ_segregation_duncan_gender.tex` | `code/stata/unemp_risk_analysis.do` |
