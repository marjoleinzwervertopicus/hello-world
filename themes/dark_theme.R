pink <- "#ff87d3"
light_color <- "#ededed"

rsthemes::rstheme(
  theme_dark = TRUE,
  theme_name = "test_theme",
  ui_background = "#004975", #ui background
  ui_foreground = light_color, #ui tab letters color. 
  code_string = "#7afffd", #string color and 'function' color
  code_function = pink, #brackets
  code_value = "#de7dff", #operators and numbers?
  code_variable = "#ede900", #?
  code_message = "#ffbe54", #error/warning/message color + bool
  # ui_rstudio_background = "#FFFFFF", #tab color
  ui_selection = 'transparentize(#80d1e8, 0.6)', #line selection color
  ui_cursor = light_color,
  code_comment = "#45ed72",
  code_identifier = light_color, #variable names color
  ui_rstudio_tabs_inactive_foreground = light_color, #tab letters
  code_operator = pink, #operators
  code_reserved = pink,
  ui_line_active_selection = "opacify($ui_selection, 0.5)"
  # ui_rstudio_foreground = light_color
)

#test
a <- function(a = 2) {
  test <- "string"
  a <-TRUE
  b <- NULL
  d <- rlang::test
}