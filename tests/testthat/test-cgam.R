if (require("testthat") &&
  require("insight") &&
  require("cgam")) {
  context("insight, model_info")

  data(cubic, package = "cgam")
  m <- cgam(y ~ incr.conv(x), data = cubic)

  test_that("n_obs", {
    expect_equal(n_obs(m), 50)
  })

  test_that("find_formula", {
    expect_length(find_formula(m), 1)
    expect_equal(
      find_formula(m),
      list(conditional = as.formula("y ~ incr.conv(x)"))
    )
  })

  test_that("find_terms", {
    expect_equal(find_terms(m), list(
      response = "y",
      conditional = "incr.conv(x)"
    ))
    expect_equal(
      find_terms(m, flatten = TRUE),
      c("y", "incr.conv(x)")
    )
  })

  test_that("get_data", {
    expect_equal(nrow(get_data(m)), 50)
    expect_equal(colnames(get_data(m)), c("y", "x"))
  })

  test_that("get_response", {
    expect_equal(get_response(m), cubic$y)
  })

  test_that("is_multivariate", {
    expect_false(is_multivariate(m))
  })

  test_that("is_model", {
    expect_true(is_model(m))
  })

  test_that("find_statistic", {
    expect_identical(find_statistic(m), "t-statistic")
  })
}
