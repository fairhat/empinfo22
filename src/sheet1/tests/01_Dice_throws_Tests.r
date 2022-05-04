test_that("dice_throw returns N / 3 number of throws with a throw size of M", {
  expect_equal(nrow(dice_throw(100 * 3)), 100)
  expect_equal(ncol(dice_throw(100, 4)), 4)
})

test_that("throw_result sum of matches", {
  throw = dice_throw(100000)
  expect_equal(throw_result(throw) > 200, T)
})