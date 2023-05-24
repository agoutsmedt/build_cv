library(tidyverse)
data_path <- "https://docs.google.com/spreadsheets/d/13riQiHaGL4pte_lobGgRBAO2t_XeQ1wbVOBa-ZpId4s/edit?usp=sharing"
source("build_ref.R")

cnrs_rank <- FALSE
for(language in c("fr", "en")){
  for(cv in c("short", "long")){
    rmarkdown::render(here::here("build_cv.Rmd"),
                      output_file = here::here(glue::glue("cv_{cv}_goutsmedt_{language}.pdf")))
  }
}

