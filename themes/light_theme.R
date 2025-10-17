pink <- "#ff00b7"
black <- "#000000"

rsthemes::rstheme(
  theme_dark = FALSE,
  theme_name = "test_theme",
  ui_background = "#fffafd", #ui background
  ui_foreground = black, #ui tab letters color. 
  code_string = "#0088d6", #string color and 'function' color
  code_function = pink, #brackets
  code_value = "#d359ff", #operators and numbers?
  code_variable = "#ede900", #?
  code_message = "#ff002f", #error/warning/message color + bool
  # ui_rstudio_background = "#FFFFFF", #tab color
  ui_selection = 'transparentize(#80d1e8, 0.6)', #line selection color
  ui_cursor = black,
  code_comment = "#00a857",
  code_identifier = black, #variable names color
  ui_rstudio_tabs_inactive_foreground = black, #tab letters
  code_operator = pink, #operators
  code_reserved = pink,
  ui_line_active_selection = "opacify($ui_selection, 0.5)",
  ui_margin_line = "transparentize(#80d1e8, 1.0)"
  # ui_rstudio_foreground = light_color
)

#test
a <- function(a = 2) {
  test <- "string"
  a <- TRUE
  b <- NULL
  d <- rlang::test
}