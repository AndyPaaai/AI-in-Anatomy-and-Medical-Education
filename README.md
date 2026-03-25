# AI in Anatomy and Medical Education

This repository contains the data, search criteria, and analytical code for the perspective article:
**"Artificial Intelligence in Anatomy and Medical Education: Growth, Thematic Structure, Collaboration, and Global Inequality"**

## Overview

Artificial intelligence (AI) is increasingly shaping the landscape of anatomy-related medical education, from image-based learning and simulation to adaptive educational technologies and generative tools. However, the structure of this literature and the factors associated with its visibility remain insufficiently examined. 

Drawing on a Scopus-based dataset of **598 articles and reviews published between 2000 and 2026**, this study uses descriptive, network-based, and exploratory inferential analyses to examine how the field has developed. We focus on three primary issues:
1. Temporal growth
2. Thematic and geographic structure
3. Bibliometric correlates of visibility

---

## Repository Contents

### 1. `Supplementary Material/`
This folder contains the raw data and the exact parameters used for literature retrieval:

*   **`Supplementary Material 1.docx` (Search Strategy & Criteria)**
    *   Contains the full, reproducible search criteria.
    *   Includes the specific Scopus search string used.
    *   Outlines the specific domains, sub-domains, and Boolean operators utilized to build the corpus at the intersection of Artificial Intelligence, Anatomy, and Medical Education.

*   **`Supplementary Material 2.csv` (Scopus Dataset)**
    *   The raw data export from Scopus (exported March 21, 2026).
    *   Contains the 598 bibliographic records (articles and reviews) analyzed in the study.
    *   Includes metadata such as Authors, Author Affiliations, Year, Source Title, Document Type, Open Access status, and Citation Counts (`Cited by`).

### 2. `src/`
This folder contains the analytical code used to process the dataset and generate the results:

*   **`code.R` (Main Analysis Script)**
    *   A comprehensive R script used for all data manipulation, descriptive statistics, and inferential modeling. It follows a structured pipeline:
        1.  **Basic Data Cleaning:** Standardizing strings, cleaning missing values, and filtering by year criteria (2000–2026).
        2.  **Variable Derivation:** Creating variables for `article_age`, `citations_per_year`, log-transformed citations, number of authors, and a simplified `doc_type` binary.
        3.  **Geographic Classification:** Using regex and the `countrycode` package to extract the first author’s country from the complex Scopus affiliation string.
        4.  **Collaboration Structure:** Parsing multiple affiliations to determine single-country vs. international collaboration.
        5.  **Income-Group Mapping:** Manually mapping the extracted countries to the *World Bank 2025* income classifications (High income, Upper middle income, Lower middle income, Low income) and generating summary tables (Table 1).
        6.  **Descriptive Figures (`ggplot2`):** Plotting annual publication output by document type (Figure 1a), top 10 contributing countries (Figure 1b), and top 10 source journals (Figure 1c).
        7.  **Exploratory Inferential Analysis:** Fitting a multivariable linear regression model (`lm(log_citations_per_year ~ ...)`) to examine the association between citation visibility and factors like international collaboration, document type, open access, author count, and publication year (Table 2).

## Reproducibility and Requirements

To run the `src/code.R` script, you will need an R environment with the following packages installed:
```r
install.packages(c("readr", "dplyr", "stringr", "tidyr", "ggplot2", "forcats", "broom", "scales", "tibble", "countrycode"))
```

*Note: The network visualizations for country co-authorship (Figure 2) and keyword co-occurrence (Figure 3) presented in the manuscript were constructed separately using **VOSviewer**, based on the bibliometric data derived from this corpus.*
