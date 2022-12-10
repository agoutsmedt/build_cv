library(bib2df)
references <- bib2df("bibliography.bib") %>% 
  janitor::clean_names() %>% 
  mutate(journal = ifelse(category == "PHDTHESIS", school, journal),
         journal = ifelse(category == "MISC", "R package", journal),
         doi = ifelse(category == "MISC", annotation, doi),
         annotation = ifelse(category == "MISC", NA, annotation),
         type = str_extract(keywords, "ongoing-pub|published|other-pub|packages")) %>% 
  select(category, bibtexkey, author, title, booktitle, chapter, journal, year, month, volume, number, pages, doi, annotation, type) %>% 
  unnest_longer(author) %>% 
  mutate(across(all_of(c("author", "title", "journal")), ~str_remove_all(., "\\{|\\}")),
         across(all_of(c("author", "title", "journal")), ~str_replace_all(., "\\\\'e", "é")),
         across(all_of(c("author", "title", "journal")), ~str_replace_all(., "\\\\'o", "ó")),
         across(all_of(c("author", "title", "journal")), ~str_replace_all(., "\\\\`a", "à"))) %>% 
  mutate(first_name = str_extract(author, "(?<=, ).*"),
         surname = str_extract(author, ".*(?=,)"),
         .before = author) %>% 
  group_by(bibtexkey) %>% 
  mutate(rownumber = row_number(),
         author = ifelse(rownumber > 1, paste(first_name, surname), author),
         author = paste0(author, collapse = ", ")) %>%
  filter(rownumber == max(rownumber))

references_complete <- bind_rows(references %>% mutate(lang = "en"),
                        references %>% mutate(lang = "fr")) %>% 
mutate(author = ifelse(rownumber > 1 & lang == "en",
                         str_replace(author, first_name, paste0("and ", first_name)),
                         author),
       author = ifelse(rownumber > 1 & lang == "fr",
                       str_replace(author, first_name, paste0(" et ", first_name)),
                       author),
       author = str_replace(author, "Goutsmedt, Aurélien", "**Goutsmedt, Aurélien**"),
       author = str_replace(author, "Aurélien Goutsmedt", "**Aurélien Goutsmedt**"),
       info_pub = ifelse(! is.na(number), paste0(volume, "(", number, "): ", pages), volume),
       reference = paste0(author, ". (",
                          year, "). ",
                          title, ". *",
                          journal, "*"),
       reference = ifelse(! is.na(info_pub), 
                          paste0(reference, ", ", info_pub, "."),
                          paste0(reference, ".")))

references_complete %>% 
  sheet_write(data_path, sheet = "Publications")
