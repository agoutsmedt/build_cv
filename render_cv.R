pacman::p_load(tidyverse, openxlsx, here)
xlsx_path <- here::here("CV_data.xlsx")

data_path <- "https://docs.google.com/spreadsheets/d/13riQiHaGL4pte_lobGgRBAO2t_XeQ1wbVOBa-ZpId4s/edit?usp=sharing"
source("build_ref.R")

cnrs_rank <- FALSE
for (language in c("fr", "en")) {
  for (cv in c("short", "long")) {
    rmarkdown::render(
      here::here("build_cv.Rmd"),
      output_file = here::here(glue::glue("cv_{cv}_goutsmedt_{language}.pdf"))
    )
  }
}

# for (language in c("fr", "en")) {
#   for (cv in c("short", "long")) {
#     quarto::quarto_render(
#       here::here("build_cv.qmd"),
#       output_file = here::here(glue::glue("cv_{cv}_goutsmedt_{language}.pdf"))
#     )
#   }
# }

# Special CV: FRHE
language <- "fr"
cv <- "short"
rmarkdown::render(
  here::here("cv_frhe.Rmd"),
  output_file = here::here(glue::glue("cv_goutsmedt_frhe.pdf"))
)
