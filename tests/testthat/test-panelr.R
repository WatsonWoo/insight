if (require("testthat") && require("insight") && require("panelr")) {
  context("insight, panelr")

  data("WageData")
  wages <- panel_data(WageData, id = id, wave = t)
  m1 <- wbm(lwage ~ lag(union) + wks | blk + fem | blk * lag(union), data = wages)
  m2 <- wbm(lwage ~ lag(union) + wks | blk + fem | blk * (t | union), data = wages)

  test_that("model_info", {
    expect_true(model_info(m1)$is_linear)
    expect_true(model_info(m2)$is_linear)
  })

  test_that("find_predictors", {
    expect_identical(find_predictors(m1), list(conditional = c("union", "wks"), instruments = c("blk", "fem")))
    expect_identical(find_predictors(m1, flatten = TRUE), c("union", "wks", "blk", "fem"))
    expect_identical(find_predictors(m1, effects = "random"), list(random = "lag(union)"))

    expect_identical(find_predictors(m2), list(conditional = c("union", "wks"), instruments = c("blk", "fem")))
    expect_identical(find_predictors(m2, effects = "random"), list(random = "union"))
  })

  test_that("find_random", {
    expect_identical(find_random(m1), list(random = "lag(union)"))
    expect_identical(find_random(m2), list(random = "union"))
  })

  test_that("get_random", {
    expect_equal(get_random(m1)[[1]], model.frame(m1)$`lag(union)`)
    expect_equal(get_random(m2)[[1]], model.frame(m2)$union)
  })

  test_that("find_response", {
    expect_identical(find_response(m1), "lwage")
  })

  test_that("get_response", {
    expect_equal(get_response(m1), model.frame(m1)$lwage)
  })

  test_that("get_predictors", {
    expect_equal(colnames(get_predictors(m1)), c("lag(union)", "wks", "blk", "fem"))
    expect_equal(colnames(get_predictors(m2)), c("lag(union)", "wks", "blk", "fem"))
  })

  test_that("link_inverse", {
    expect_equal(link_inverse(m1)(.2), .2, tolerance = 1e-5)
  })

  test_that("get_data", {
    expect_equal(nrow(get_data(m1)), 3570)
    expect_equal(
      colnames(get_data(m1)),
      c("lwage", "id", "t", "lag(union)", "wks", "blk", "fem", "imean(lag(union))",
        "imean(wks)", "lag(union)*blk", "imean(lag(union):blk)", "lag(union):blk")
    )
    expect_equal(
      colnames(get_data(m2)),
      c("lwage", "id", "t", "lag(union)", "wks", "blk", "fem", "union",  "imean(lag(union))", "imean(wks)")
    )
  })

  test_that("find_formula", {
    expect_length(find_formula(m1), 3)
    expect_equal(
      find_formula(m1),
      list(
        conditional = as.formula("lwage ~ lag(union) + wks"),
        instruments = as.formula("~blk + fem"),
        random = as.formula("~blk | lag(union)")
      )
    )

    expect_equal(
      find_formula(m2),
      list(
        conditional = as.formula("lwage ~ lag(union) + wks"),
        instruments = as.formula("~blk + fem"),
        random = as.formula("~blk * t | union")
      )
    )
  })

  test_that("find_terms", {
    expect_equal(find_terms(m1), list(response = "lwage", conditional = c("union", "wks"), instruments = c("blk", "fem"), random = "lag(union)"))
    expect_equal(find_terms(m1, flatten = TRUE), c("lwage", "union", "wks", "blk", "fem", "lag(union)"))

    expect_equal(find_terms(m2), list(response = "lwage", conditional = c("union", "wks"), instruments = c("blk", "fem"), random = "union"))
    expect_equal(find_terms(m2, flatten = TRUE), c("lwage", "union", "wks", "blk", "fem"))
  })

  test_that("n_obs", {
    expect_equal(n_obs(m1), 3570)
    expect_equal(n_obs(m2), 3570)
  })

  test_that("linkfun", {
    expect_false(is.null(link_function(m1)))
  })

  test_that("find_parameters", {
    expect_equal(
      find_parameters(m1),
      list(
        conditional = c("(Intercept)", "imean(lag(union))", "imean(wks)", "lag(union)", "wks", "blk", "fem", "lag(union):blk"),
        random = list(id = "(Intercept)")
      )
    )
    expect_equal(nrow(get_parameters(m1)), 8)

    expect_equal(
      find_parameters(m2),
      list(
        conditional = c("(Intercept)", "imean(lag(union))", "imean(wks)", "lag(union)", "wks", "blk", "fem"),
        random = list(id = "(Intercept)",
                      union = c("(Intercept)", "t")))
    )

  })

  test_that("find_variables", {
    expect_equal(
      find_variables(m1),
      list(response = "lwage", conditional = c("lag(union)", "wks"),
           instruments = c("blk", "fem"), random = c("blk", "lag(union)"))
      )
    expect_equal(
      find_variables(m2),
      list(response = "lwage", conditional = c("lag(union)", "wks"),
           instruments = c("blk", "fem"), random = c("blk", "t", "union"))
    )
  })

  test_that("is_multivariate", {
    expect_false(is_multivariate(m1))
  })
}