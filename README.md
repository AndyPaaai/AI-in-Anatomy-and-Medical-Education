# AI in Anatomy and Medical Education

This repository contains the data, search criteria, and analytical code for the perspective article:
**"Artificial Intelligence in Anatomy and Medical Education: Growth, Thematic Structure, Collaboration, and Global Inequality"**

## Overview

Artificial intelligence (AI) is increasingly shaping the landscape of anatomy-related medical education. This study explores the structure of this literature and the factors associated with its visibility using a Scopus-based dataset of 598 articles and reviews published between 2000 and 2026. The repository provides all supplementary materials and code required to reproduce the descriptive bibliometric analyses, geographic and thematic structural mappings, and exploratory inferential models.

## Repository Contents

### 1. `Supplementary Material/`
This folder contains the dataset and the exact search parameters used for literature retrieval:
*   **`Supplementary Material 1.docx`**: Contains the full search criteria, including the Scopus search string and the specific domains/sub-domains queried to build the corpus.
*   **`Supplementary Material 2.csv`**: The raw data export from Scopus containing 598 bibliographic records (articles and reviews), including citation counts, author affiliations, publication years, and open access status.

### 2. `src/`
This folder contains the analytical code:
*   **`code.R`**: The comprehensive R script used for all data processing and analyses. It includes:
    *   **Data Cleaning:** Standardization of author affiliations, publication types, and open-access status.
    *   **Geographic Classification:** Extraction of the first author’s country and manual mapping to the World Bank 2025 income groups.
    *   **Descriptive Analyses:** Generation of publication trends over time (Figure 1a), identifying top producing countries (Figure 1b) and prominent source journals (Figure 1c).
    *   **Exploratory Inferential Analysis:** A multivariable linear regression model to examine the factors (collaboration type, document type, open access, team size, publication year) associated with citation visibility (Table 2).

## Requirements

To run the `code.R` script, the following R packages are required:
*   `readr`, `dplyr`, `stringr`, `tidyr`, `ggplot2`, `forcats`, `broom`, `scales`, `tibble`, `countrycode`

*(Note: Network visualizations in Figure 2 and Figure 3 of the manuscript were constructed using VOSviewer, based on data derived from this corpus).*
