for(language in c("fr", "en")){
  rmarkdown::render(here::here("build_cv.Rmd"),
                    here::here("cv_goutsmedt_{language}.pdf"))
}
