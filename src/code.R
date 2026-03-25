# =========================================================
# Artificial intelligence at the interface of anatomy and medical education
# Bibliometric, network, and exploratory inferential analyses
# Unified and cleaned R script
# =========================================================

# =========================
# 0. Packages
# =========================
library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(forcats)
library(broom)
library(scales)
library(tibble)
library(countrycode)

# =========================
# 1. Import data
# =========================
df <- read_csv("C:/Users/andya/Downloads/scopus_export_Mar 21-2026_9efb9ccf-2942-402d-ae5f-9fcfd3c27e4b.csv")

# =========================
# 2. Basic cleaning
# =========================
df <- df %>%
  mutate(
    Year = as.numeric(Year),
    `Cited by` = replace_na(as.numeric(`Cited by`), 0),
    Authors = str_squish(Authors),
    `Author full names` = str_squish(`Author full names`),
    `Source title` = str_squish(`Source title`),
    `Document Type` = str_squish(`Document Type`),
    `Open Access` = str_squish(`Open Access`),
    Affiliations = str_squish(Affiliations),
    `Authors with affiliations` = str_squish(`Authors with affiliations`)
  ) %>%
  filter(!is.na(Year), Year >= 2000, Year <= 2026)

# =========================
# 3. Derived bibliometric variables
# =========================
df <- df %>%
  mutate(
    article_age = 2026 - Year + 1,
    citations = `Cited by`,
    citations_per_year = citations / article_age,
    log_citations_per_year = log1p(citations_per_year),
    
    authors_n = if_else(
      !is.na(Authors) & Authors != "",
      str_count(Authors, ";") + 1,
      NA_real_
    ),
    
    doc_type_simple = case_when(
      str_to_lower(`Document Type`) == "article" ~ "Article",
      str_to_lower(`Document Type`) == "review"  ~ "Review",
      TRUE ~ "Other"
    ),
    
    oa = case_when(
      str_detect(`Open Access`, regex("open", ignore_case = TRUE)) ~ "Open access",
      TRUE ~ "Non-open access"
    )
  )

# =========================
# 4. First-author affiliation country
#    Extract first-author block and identify the last valid country
# =========================
df <- df %>%
  mutate(
    first_author = str_trim(str_extract(Authors, "^[^;]+")),
    first_author_affil_block = str_trim(str_extract(`Authors with affiliations`, "^[^;]+"))
  ) %>%
  mutate(
    first_author_affil_block = first_author_affil_block %>%
      str_replace_all("& amp;", "&") %>%
      str_replace_all("&amp;", "&") %>%
      str_replace_all("\\s+", " ") %>%
      str_trim()
  )

valid_countries <- unique(countrycode::codelist$country.name.en)
valid_countries <- valid_countries[!is.na(valid_countries)]

valid_countries <- unique(c(
  valid_countries,
  "United States",
  "United Kingdom",
  "South Korea",
  "Korea",
  "Hong Kong",
  "Taiwan",
  "Viet Nam",
  "Russian Federation",
  "Syrian Arab Republic",
  "Iran",
  "Turkey"
))

extract_valid_country <- function(x, valid_countries) {
  if (is.na(x) || x == "") return(NA_character_)
  
  parts <- unlist(str_split(x, ","))
  parts <- str_trim(parts)
  parts <- parts[parts != ""]
  
  for (p in rev(parts)) {
    if (p %in% valid_countries) return(p)
  }
  
  return(NA_character_)
}

df$first_author_country <- vapply(
  df$first_author_affil_block,
  extract_valid_country,
  FUN.VALUE = character(1),
  valid_countries = valid_countries
)

# Standardize country names to match the World Bank-style reference table
df <- df %>%
  mutate(
    first_author_country = recode(
      first_author_country,
      "South Korea" = "Korea, Rep.",
      "Korea" = "Korea, Rep.",
      "Russia" = "Russian Federation",
      "Iran" = "Iran, Islamic Rep.",
      "Turkey" = "Türkiye",
      "Hong Kong" = "Hong Kong SAR, China",
      "Taiwan" = "Taiwan, China",
      .default = first_author_country
    )
  )

# =========================
# 5. Country-level collaboration from all affiliations
# =========================
affil_long <- df %>%
  select(EID, Affiliations) %>%
  filter(!is.na(Affiliations), Affiliations != "") %>%
  separate_rows(Affiliations, sep = ";") %>%
  mutate(
    Affiliations = str_squish(Affiliations),
    country = str_extract(Affiliations, "[^,]+$"),
    country = str_squish(country)
  ) %>%
  filter(!is.na(country), country != "")

country_doc <- affil_long %>%
  distinct(EID, country)

country_counts <- country_doc %>%
  count(EID, name = "countries_n")

df <- df %>%
  left_join(country_counts, by = "EID") %>%
  mutate(
    countries_n = replace_na(countries_n, 1),
    international_collab = case_when(
      countries_n > 1 ~ "International collaboration",
      TRUE ~ "Single-country publication"
    )
  )

# =========================
# 6. Income-group classification (World Bank 2025-based manual reference)
# =========================
income_ref <- tribble(
  ~country, ~income_group,
  "Australia", "High income",
  "Austria", "High income",
  "Bangladesh", "Lower middle income",
  "Belgium", "High income",
  "Brazil", "Upper middle income",
  "Canada", "High income",
  "Chile", "High income",
  "China", "Upper middle income",
  "Colombia", "Upper middle income",
  "Croatia", "High income",
  "Cuba", "Upper middle income",
  "Cyprus", "High income",
  "Denmark", "High income",
  "Ecuador", "Upper middle income",
  "Egypt", "Lower middle income",
  "Finland", "High income",
  "France", "High income",
  "Germany", "High income",
  "Greece", "High income",
  "Grenada", "Upper middle income",
  "Hong Kong SAR, China", "High income",
  "India", "Lower middle income",
  "Indonesia", "Upper middle income",
  "Iran, Islamic Rep.", "Lower middle income",
  "Ireland", "High income",
  "Israel", "High income",
  "Italy", "High income",
  "Japan", "High income",
  "Jordan", "Upper middle income",
  "Korea, Rep.", "High income",
  "Luxembourg", "High income",
  "Malaysia", "Upper middle income",
  "Malta", "High income",
  "Mexico", "Upper middle income",
  "Morocco", "Lower middle income",
  "Netherlands", "High income",
  "New Zealand", "High income",
  "Nigeria", "Lower middle income",
  "Norway", "High income",
  "Oman", "High income",
  "Pakistan", "Lower middle income",
  "Philippines", "Lower middle income",
  "Poland", "High income",
  "Portugal", "High income",
  "Qatar", "High income",
  "Romania", "High income",
  "Russian Federation", "Upper middle income",
  "Saudi Arabia", "High income",
  "Serbia", "Upper middle income",
  "Singapore", "High income",
  "Slovakia", "High income",
  "South Africa", "Upper middle income",
  "Spain", "High income",
  "Sweden", "High income",
  "Switzerland", "High income",
  "Syrian Arab Republic", "Low income",
  "Taiwan, China", NA_character_,
  "Thailand", "Upper middle income",
  "Türkiye", "Upper middle income",
  "Ukraine", "Lower middle income",
  "United Arab Emirates", "High income",
  "United Kingdom", "High income",
  "United States", "High income",
  "Viet Nam", "Lower middle income"
)

df <- df %>%
  left_join(income_ref, by = c("first_author_country" = "country")) %>%
  rename(income_group_final = income_group)

# =========================
# 7. Table of scientometric indicators by income group
# =========================
income_table <- df %>%
  filter(!is.na(income_group_final)) %>%
  group_by(income_group_final) %>%
  summarise(
    n_documents = n(),
    percent = round(100 * n() / sum(!is.na(df$income_group_final)), 1),
    median_citations = median(citations, na.rm = TRUE),
    iqr_citations = IQR(citations, na.rm = TRUE),
    median_citations_per_year = median(citations_per_year, na.rm = TRUE),
    iqr_citations_per_year = IQR(citations_per_year, na.rm = TRUE),
    median_authors = median(authors_n, na.rm = TRUE),
    iqr_authors = IQR(authors_n, na.rm = TRUE),
    prop_open_access = round(100 * mean(oa == "Open access", na.rm = TRUE), 1),
    prop_international_collab = round(
      100 * mean(international_collab == "International collaboration", na.rm = TRUE), 1
    ),
    .groups = "drop"
  ) %>%
  mutate(
    income_group_final = factor(
      income_group_final,
      levels = c("Low income", "Lower middle income", "Upper middle income", "High income")
    )
  ) %>%
  arrange(income_group_final)

income_table_pretty <- income_table %>%
  mutate(
    `Documents, n (%)` = paste0(n_documents, " (", percent, "%)"),
    `Citations, median [IQR]` = paste0(median_citations, " [", iqr_citations, "]"),
    `Citations/year, median [IQR]` = paste0(
      round(median_citations_per_year, 2), " [", round(iqr_citations_per_year, 2), "]"
    ),
    `Authors, median [IQR]` = paste0(median_authors, " [", iqr_authors, "]"),
    `Open access, %` = prop_open_access,
    `International collaboration, %` = prop_international_collab
  ) %>%
  select(
    `Income group` = income_group_final,
    `Documents, n (%)`,
    `Citations, median [IQR]`,
    `Citations/year, median [IQR]`,
    `Authors, median [IQR]`,
    `Open access, %`,
    `International collaboration, %`
  )

income_table_pretty

# =========================
# 8. Data for descriptive figures
# =========================

# 8.1 Annual output by document type
pubs_year_type <- df %>%
  filter(doc_type_simple %in% c("Article", "Review")) %>%
  count(Year, doc_type_simple, name = "n") %>%
  complete(
    Year = full_seq(range(df$Year), 1),
    doc_type_simple = c("Article", "Review"),
    fill = list(n = 0)
  ) %>%
  mutate(
    doc_type_simple = factor(doc_type_simple, levels = c("Article", "Review"))
  )

# 8.2 Top 10 contributing countries
top_countries <- country_doc %>%
  count(country, sort = TRUE, name = "n") %>%
  slice_head(n = 10)

# 8.3 Top 10 source journals
top_journals <- df %>%
  count(`Source title`, sort = TRUE, name = "n") %>%
  slice_head(n = 10)

# =========================
# 9. Figure 1: Annual publication output
# =========================
pal_doc <- c(
  "Article" = "#2A9D8F",
  "Review"  = "#C96A2D"
)

fig1 <- pubs_year_type %>%
  ggplot(aes(x = Year, y = n, group = doc_type_simple)) +
  geom_area(
    data = ~ dplyr::filter(.x, doc_type_simple == "Review"),
    aes(fill = doc_type_simple),
    alpha = 0.25,
    position = "identity"
  ) +
  geom_line(aes(color = doc_type_simple), linewidth = 1.1) +
  scale_x_continuous(
    limits = c(2000, 2026),
    breaks = seq(2000, 2026, by = 2),
    minor_breaks = NULL
  ) +
  scale_y_continuous(
    breaks = seq(0, 180, by = 10),
    labels = comma
  ) +
  scale_color_manual(values = pal_doc, name = "Document type") +
  scale_fill_manual(values = pal_doc, name = "Document type") +
  labs(
    title = "Annual publication output",
    x = "Year",
    y = "Number of publications"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.title = element_text(face = "bold"),
    legend.position = "right",
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold")
  )

fig1

# =========================
# 10. Figure 2: Top 10 contributing countries
# =========================
fig2 <- ggplot(top_countries, aes(x = n, y = fct_reorder(country, n))) +
  geom_col(width = 0.72, fill = "#4C6A92") +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Top 10 contributing countries",
    x = "Number of publications",
    y = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position = "none",
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold")
  )

fig2

# =========================
# 11. Figure 3: Top 10 source journals
# =========================
fig3 <- ggplot(top_journals, aes(x = n, y = fct_reorder(`Source title`, n))) +
  geom_col(width = 0.72, fill = "#7A8F63") +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Top 10 source journals",
    x = "Number of publications",
    y = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position = "none",
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold")
  )

fig3

# =========================
# 12. Exploratory inferential analysis
#     Outcome: log(citations_per_year + 1)
# =========================
df_model <- df %>%
  filter(
    doc_type_simple %in% c("Article", "Review"),
    !is.na(log_citations_per_year),
    !is.na(international_collab),
    !is.na(authors_n),
    !is.na(oa),
    !is.na(Year)
  )

model <- lm(
  log_citations_per_year ~ international_collab + doc_type_simple + oa + authors_n + Year,
  data = df_model
)

summary(model)

model_table <- tidy(model, conf.int = TRUE) %>%
  mutate(
    term = recode(
      term,
      `(Intercept)` = "Intercept",
      `international_collabSingle-country publication` = "Single-country publication (vs international collaboration)",
      `doc_type_simpleReview` = "Review (vs Article)",
      `oaOpen access` = "Open access (vs non-open access)",
      `authors_n` = "Number of authors",
      `Year` = "Publication year"
    ),
    estimate = round(estimate, 3),
    conf.low = round(conf.low, 3),
    conf.high = round(conf.high, 3),
    p.value = ifelse(p.value < 0.001, "<0.001", sprintf("%.3f", p.value))
  ) %>%
  select(
    Variable = term,
    Beta = estimate,
    `95% CI lower` = conf.low,
    `95% CI upper` = conf.high,
    `p-value` = p.value
  )

model_table

