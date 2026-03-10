# BIS15L Group Project Typical Requirements Guide (Labs 10-16 + GOBY Example)

## Scope of this guide
This guide is built from:
- explicit project-related text in `lab10`-`lab16` `.Rmd` files
- structural and analytic review of `projects/GOBY`

I separate:
- **Explicit requirements** (directly stated in lab files)
- **Typical expectations** (inferred from the GOBY example and course pattern)

---

## 1. Explicit project requirements found in labs 10-16

### A) Group setup and grading
From `lab12/lab12_projects.Rmd`:
- Project is **100 points (~30% of course grade)**.
- Group size: **3-4 students**.
- Each student must contribute; peers evaluate each other.

### B) Required deliverables
From `lab12/lab12_projects.Rmd`:
- You must include a **Shiny app**.
- You must include a **presentation**.
- Data must follow specific guidelines and be approved.

From `lab15/lab_15_intro.Rmd`:
- Project should have a **clear story**.
- Groups give a **short presentation**.
- Project should showcase a **range of course skills** (data wrangling, visualization, mapping, etc.).

### C) Data/source expectations
From `lab12/lab12_projects.Rmd`:
- Unless approved otherwise, data should come from a **peer-reviewed journal article**.
- Include the **article** in your final project.
- Find multiple candidate datasets first, then pick best one.
- Data should include a mix of **continuous + categorical** variables.

From `lab12/hw12.Rmd` and `lab13/lab13_intro.Rmd`:
- Exactly **one GitHub repo per group**.
- Add all group members as collaborators, plus instructors (`jmledford3115`, `bryshalm`).
- Add a **data/** folder with candidate datasets + original articles.
- By lab 13 period: data imported and ready for instructor review/approval.

### D) Process expectations
From `lab14/lab_14_intro.Rmd`:
- Team should define:
  - questions
  - variables used to answer those questions
  - analyses
  - presentation plan
  - member responsibilities

---

## 2. What the GOBY repo looks like (reference implementation)

## Repository layout (high-level)
`projects/GOBY` contains:
- `README.md` (project overview, contributions, data source)
- `data/` (main dataset + codebook/readme docx)
- `Exploring Data/` (multiple member Rmd exploratory notebooks + rendered html + output graphics)
- `Shiny App/` (standalone Shiny Rmd + local assets)
- `maps/`, `graphs/` (saved figures)
- `Background reading/` (papers)
- presentation file (`.pptx`)

### File volume snapshot
- Rmd files: **8**
- HTML outputs: **6**
- CSV files: **4** (same dataset copied across folders)
- PNG files: **41**
- PDFs: **2**
- Presentation deck: **1**

Interpretation: GOBY is a multi-artifact repo (analysis notebooks + app + figures + reading + presentation), not just one single script.

---

## 3. GOBY data profile (quantitative metrics)

Using `projects/GOBY/data/CA_visibility_data.csv`:
- Rows: **26,633**
- Columns: **22**
- Unique sites: **23**
- Geographic scope: **California only** (`State = CA`)
- Year span: **2011-2021** (11 years)

### Variables used
Columns include:
- Metadata/ID style: `Dataset`, `SiteCode`, `POC`, `Date`, `Percentile`, `SiteName`, `State`
- Spatial continuous: `Latitude`, `Longitude`, `Elevation`
- Main continuous analysis metrics:
  - `ammNO3f_Val`
  - `ammSO4f_Val`
  - `ECf_Val`
  - `OMCf_Val`
  - `SOILf_Val`
  - `SVR_Val`
- Unit columns for each metric (`*_Unit`)

### Missingness in core analysis variables
Sentinel `-999` used for missing and converted to `NA`.
- `SVR_Val`: 2,614 missing (**9.81%**)
- `OMCf_Val`: 2,251 missing (**8.45%**)
- `ammNO3f_Val`: 2,180 missing (**8.19%**)
- `ECf_Val`: 2,162 missing (**8.12%**)
- `SOILf_Val`: 1,999 missing (**7.51%**)
- `ammSO4f_Val`: 1,988 missing (**7.46%**)

Interpretation: this is a realistic, moderately sparse observational dataset; not fully clean.

---

## 4. What analyses GOBY actually performs

## A) Data cleaning and structuring
Common operations across member notebooks:
- read CSV
- convert `-999` to `NA`
- standardize column names (`janitor::clean_names()` in some notebooks)
- parse/separate dates into month/day/year
- basic missingness checks (`naniar::miss_var_summary`)

## B) Exploratory data analysis (EDA)
- Distinct counts of sites/site codes/state.
- Summary tables for site metadata.
- Inspection of site coverage and temporal coverage.

## C) Mapping analyses
- Build California bounding box from lat/long.
- Plot site points on terrain map.
- Map colored by elevation and by site.
- Single-site map examples (e.g., Yosemite).

## D) Time-series and grouped summaries
Core pattern:
- Group by `SiteName` and `year`.
- Compute yearly means for 6 key air-quality/visibility metrics.
- Plot faceted site-level trajectories over time.

## E) Event-linked interpretation
- Site-specific yearly trends for Yosemite and Lassen Volcanic NP.
- Fire-context annotations (e.g., Ferguson Fire, Dixie Fire).
- Focus on selected pollutants (ammNO3, ammSO4, OMC).

## F) Interactive apps
GOBY includes two app concepts:
1. **Site-wise yearly visibility app** (radio/select input for site; line plot of mean SVR over years)
2. **Seasonal metrics app** (site + metric selectors; grouped seasonal bars over years)

Both implemented with `shiny` + `shinydashboard` patterns.

## G) Communication outputs
- Multiple exploratory Rmd notebooks per member.
- Consolidated group exploratory notebook.
- Shiny app Rmd.
- Rendered html artifacts.
- Saved publication/presentation style plots.
- Slide deck and project README.

---

## 5. Typical BIS15L project blueprint (actionable planning target)

Use this as a practical target if you want to model a project after GOBY while matching stated course expectations.

## 1) Team and repo setup (Week 1 of project)
- Group size: **3-4**.
- Create **one shared GitHub repo**.
- Add collaborators (all members + instructors).
- Define owner for repo hygiene and branch/merge coordination.

## 2) Data selection and approval
- Start with **2-3 candidate datasets** + their articles.
- Finalize **1 approved primary dataset**.
- Ensure your final dataset has:
  - at least one strong categorical dimension (site/group/treatment/class)
  - multiple continuous variables for analysis
  - enough rows for grouped summaries over time or categories

### Suggested sizing target (based on GOBY profile)
- Minimum workable: ~**2,000+ rows**, **10+ columns**
- Strong target: **10,000-30,000 rows**, **15-25 columns**
- Include at least **5-6 continuous analyzable variables**

(These are inferred targets, not explicit hard rules.)

## 3) Required analysis components
You should include all of the following blocks:

1. **Data QA/Cleaning block**
- Document missing-value strategy.
- Parse/engineer key variables (e.g., date fields).
- Show at least one missingness summary table/plot.

2. **EDA block**
- Variable-level overview and data dictionary notes.
- Distinct counts for key entities.
- At least 2 exploratory visuals.

3. **Core analysis block**
- Grouped summaries (e.g., by site/year/category).
- At least **4-6 primary plots** tied directly to research questions.
- At least one comparison across categories or over time.

4. **Mapping block** (if geo data exists)
- At least one map with site/event locations.
- Prefer one statewide/overview and one focused/local map.

5. **Interactive Shiny app block** (explicit requirement)
- At least one app with:
  - >=1 user input control
  - >=1 reactive plot/table output
  - clean labels/units/titles

6. **Interpretation/story block**
- Link plots to a narrative question.
- Explain what trends mean and what limitations remain.

## 4) Deliverables checklist
For a "complete" repo, target these artifacts:
- `README.md` with project summary, contributors, data source, and links.
- `data/` with final dataset + source article(s) + codebook/readme.
- `analysis/` or equivalent Rmd notebooks (individual and/or integrated).
- `Shiny App/` app code and local assets.
- `figures/` or `graphs/` with saved output images.
- Final presentation slides.
- Rendered HTML outputs for key Rmds.

## 5) Work split model (recommended)
A typical high-functioning split (mirrors GOBY style):
- Member A: data ingestion/cleaning + repo coordination
- Member B: mapping/geo visualization
- Member C: time-series or statistical analysis
- Member D: Shiny app + polish/integration
- All members: final interpretation + presentation

## 6) Minimum vs strong project targets

### Minimum acceptable (course requirement aligned)
- 1 approved dataset + source article.
- 1 shared repo with proper collaborators.
- 1 Shiny app.
- 1 presentation.
- Evidence of wrangling + visualization + interpretation.

### Strong project (GOBY-like)
- 1 large observational dataset (10k+ rows).
- 5-6 core numeric outcome variables analyzed.
- Time and category stratification.
- Map component + event/context overlay.
- 1-2 Shiny apps or one robust multi-view app.
- Multiple cleaned outputs and polished figures.

---

## 6. Practical planning template you can copy

## Project planning table
- Research question(s):
- Dataset source + citation:
- Candidate datasets reviewed (n=):
- Final dataset dimensions (rows x cols):
- Key categorical vars:
- Key continuous vars:
- Missing data plan:
- Planned analyses (bullet list):
- Planned visuals (count + type):
- Mapping included? (yes/no):
- Shiny app inputs/outputs:
- Member responsibilities:
- Final presentation story arc:

---

## 7. Important note on certainty
- Items in Sections 1 are directly stated in the lab files.
- Numeric targets (e.g., row counts, number of plots, variable counts) are **inferred from GOBY and should be treated as strong heuristics**, not official hard cutoffs unless your rubric says so.

