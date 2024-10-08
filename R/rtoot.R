library(rtoot)
library(tidyverse)

token <- auth_setup("fosstodon.org", "user")

verify_credentials(token, verbose = TRUE)

account_results <- search_accounts("fontikar", token = token)

my_account_results <- get_account_statuses(account_results$id) 

silly_toot_id <- my_account_results |> 
  filter(str_detect(content, "Python")) |> 
  pull(id)

silly_toot_results <- get_status(silly_toot_id)

silly_context <- get_context(silly_toot_id)

silly_context$descendants |> View() # This is what I want. Just need to clean up the content column...

### --- 

silly_descendants <- silly_context |> 
  pluck("descendants")

# Can I exclude my replies?
silly_descendants |> 
  filter(str_detect(content, "fontikar")) |> 
  View()

silly_context |> 
  pluck("descendants") |> 
  select(id, uri, content, ends_with("id"), card, account)

# Maybe better to filter on card 
silly_descendants$card |> str()

# Count the empty card slots
silly_descendants$card |> 
  map(is_empty) |> 
  list_c() |> table()

# Not exactly what I want
card_filled <- discard(silly_descendants$card , is_empty) 

# Function to extract all the urls
card_filled[[1]]$url
      
tibble(link = card_filled |> 
         map(~pluck(.x, "url")) |> 
         list_c()) |> 
  write_csv("output/wrangled_github_links.csv")
