data_path <- "https://docs.google.com/spreadsheets/d/13riQiHaGL4pte_lobGgRBAO2t_XeQ1wbVOBa-ZpId4s/edit?usp=sharing"
source("build_ref.R")

for(language in c("fr", "en")){
  rmarkdown::render(here::here("build_cv.Rmd"),
                    output_file = here::here(glue::glue("cv_goutsmedt_{language}.pdf")))
}
