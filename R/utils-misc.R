# converts a character vector into a quotes list separated by a comma, eg 'a', 'b'
quoted_list <- function(x) {
  paste(shQuote(x, type = "csh"), collapse = ", ")
}

# used in the as_flex_table (and friends) functions for inserting calls
add_expr_after <- function(calls, add_after, expr, new_name = NULL) {
  # checking input
  if (!rlang::is_string(add_after) || !add_after %in% names(calls)) {
    stop(glue("`add_after=` must be one of {quoted_list(names(calls))}"))
  }

  # position to insert, and name of list
  index <- which(names(calls) == add_after)
  new_name <- new_name %||% "user_added"
  new_list <- list(expr) %>% set_names(new_name)

  # insert list
  append(calls, new_list, after = index)
}

#' gtsummary wrapper for purrr::as_mapper
#'
#' This wrapper only accepts a function or formula notation function,
#' and returns an informative message when incorrect inputs passed
#'
#' @param x function or anon. function using formula notation.
#' @param context string indicating function and arg, e.g. `context = "foo(arg=)"`
#' @noRd
#' @keywords internal

gts_mapper <- function(x, context) {
  # checking input, and giving informative error msg
  if (!rlang::is_function(x) && !rlang::is_formula(x)) {
    paste(
      "Expecting a function in argument `{context}`,\n",
      "e.g. `fun = function(x) style_pvalue(x, digits = 2)`, or\n",
      "`fun = ~style_pvalue(., digits = 2)`"
    ) %>%
      stringr::str_glue() %>%
      rlang::abort()
  }

  purrr::as_mapper(x)
}

type_check <-
  list(
    is_string =
      list(msg = "Expecting a string as the passed value.",
           fn = is_string),
    is_character =
      list(msg = "Expecting a character as the passed value.",
           fn = is.character),
    is_function =
      list(msg = "Expecting a function as the passed value.",
           fn = is.function),
    is_function_or_string =
      list(msg = "Expecting a function or a string of a function name.",
           fn = function(x) is_string(x) || is.function(x)),
    is_string_or_na =
      list(msg = "Expecting a string or NA as the passed value.",
           fn = function(x) is_string(x) || is.na(x)),
    is_named =
      list(msg = "Expecting a named vector or list as the passed value.",
           fn = is_named),
    digits =
      list(msg = "Expecting an integer, function, or a vector/list of intergers/functions as the passed value.",
           fn = function(x) rlang::is_integerish(x) || is.function(x) || purrr::every(x, ~rlang::is_integerish(.x) || is.function(.x)))
  )
