pacman::p_load(bib2df, openxlsx)

references <- bib2df("bibliography.bib") %>%
  janitor::clean_names() %>%
  mutate(
    journal = journaltitle,
    journal = ifelse(category == "PHDTHESIS", school, journal),
    journal = ifelse(
      category %in% "BOOK",
      paste0(address, ": ", publisher),
      journal
    ),
    journal = ifelse(category == "SOFTWARE", "R package", journal),
    journal = ifelse(category == "DATASET", publisher, journal),
    year = str_extract(date, "^\\d+") |> as.integer(),
    doi = ifelse(category == "SOFTWARE", annotation, doi),
    type = str_extract(
      keywords,
      "ongoing-pub|published|other-pub|invited-paper|packages"
    ),
    cv_type = str_extract(keywords, "short-cv|long-cv") %>%
      str_remove("-cv")
  ) %>%
  select(
    category,
    bibtexkey,
    author,
    title,
    booktitle,
    chapter,
    journal,
    year,
    month,
    volume,
    number,
    pages,
    doi,
    annotation,
    type,
    cv_type
  ) %>%
  unnest_longer(author) %>%
  mutate(
    across(
      all_of(c("author", "title", "journal")),
      ~ str_remove_all(., "\\{|\\}")
    ),
    across(
      all_of(c("author", "title", "journal")),
      ~ str_replace_all(., "\\\\'e", "é")
    ),
    across(
      all_of(c("author", "title", "journal")),
      ~ str_replace_all(., "\\\\'o", "ó")
    ),
    across(
      all_of(c("author", "title", "journal")),
      ~ str_replace_all(., "\\\\`a", "à")
    ),
    title_linked = ifelse(
      !is.na(doi),
      paste0("\\href{", doi, "}{", title, "}"),
      title
    ),
    preprint = ifelse(
      annotation != "" & ! category %in% c("SOFTWARE", "DATASET"),
      paste0("\\href{", annotation, "}{Preprint}"),
      NA
    )
  ) %>%
  mutate(
    first_name = str_extract(author, "(?<=, ).*"),
    surname = str_extract(author, ".*(?=,)"),
    .before = author
  ) %>%
  group_by(bibtexkey) %>%
  mutate(
    rownumber = row_number(),
    author = ifelse(
      rownumber > 1,
      paste(first_name, surname),
      author
    ),
    author = paste0(author, collapse = ", ")
  ) %>%
  filter(rownumber == max(rownumber))

references_complete <- bind_rows(
  references %>% mutate(lang = "en"),
  references %>% mutate(lang = "fr")
) %>%
  mutate(
    author = ifelse(
      rownumber > 1 & lang == "en",
      str_replace(
        author,
        first_name,
        paste0("and ", first_name)
      ),
      author
    ),
    author = ifelse(
      rownumber > 1 & lang == "fr",
      str_replace(
        author,
        first_name,
        paste0(" et ", first_name)
      ),
      author
    ),
    author = str_replace(
      author,
      "Goutsmedt, Aurélien",
      "**Goutsmedt, Aurélien**"
    ),
    author = str_replace(
      author,
      "Aurélien Goutsmedt",
      "**Aurélien Goutsmedt**"
    ),
    info_pub = ifelse(
      !is.na(number),
      paste0(volume, "(", number, "): ", pages),
      volume
    ),
    reference = paste0(
      author,
      ". (",
      year,
      "). ",
      title_linked,
      ". *",
      journal,
      "*"
    ),
    reference = ifelse(
      !is.na(info_pub),
      paste0(reference, ", ", info_pub, "."),
      paste0(reference, ".")
    ),
    reference = ifelse(
      !is.na(preprint),
      paste0(reference, " [", preprint, "]"),
      reference
    )
  ) %>%
  select(-c(title_linked, preprint, rownumber, info_pub))

arranged <- references_complete %>%
  arrange(desc(year), bibtexkey)

sheet_name <- "Publications"
if (file.exists(xlsx_path)) {
  wb <- loadWorkbook(xlsx_path)
} else {
  cli::cli_alert_danger("File {.file {xlsx_path}} does not exist.")
}

if (sheet_name %in% names(wb)) {
  existing <- tryCatch(
    readWorkbook(wb, sheet = sheet_name),
    error = function(e) NULL
  )
  if (is.null(existing) || (nrow(existing) == 0 && ncol(existing) == 0)) {
    writeData(
      wb,
      sheet = sheet_name,
      arranged,
      startRow = 1,
      colNames = TRUE
    )
  } else {
    ans <- tolower(substr(
      readline(paste0(
        "Replace sheet '",
        sheet_name,
        "' with new data? (y/n): "
      )),
      1,
      1
    ))
    if (ans == "y") {
      removeWorksheet(wb, sheet = sheet_name)
      addWorksheet(wb, sheet_name)
      writeData(
        wb,
        sheet = sheet_name,
        arranged,
        startRow = 1,
        colNames = TRUE
      )
    } else {
      invisible(NULL)
    }
  }
} else {
  addWorksheet(wb, sheet_name)
  writeData(
    wb,
    sheet = sheet_name,
    arranged,
    startRow = 1,
    colNames = TRUE
  )
}

saveWorkbook(wb, xlsx_path, overwrite = TRUE)
