dice_throw <- function(times = 100000, size = 3) {
  replicate(trunc(times / 3), sample(1:6, size))
}

filter_throw <- function(throw, matches = c(3, 4, 5)) {
  table(apply(throw, 2, function(x) {
    sum(x == matches)
  }))
}

throw_result <- function(throw, matches = c(3, 4, 5)) {
  as.data.frame(filter_throw(throw, matches))$Freq[4]
}

print("Test with 100k throws and matching 3,4,5:")
test_throw <- dice_throw()
test_filter <- filter_throw(test_throw, c(3, 4, 5))
test_result <- throw_result(test_throw, c(3, 4, 5))
print("Result as table [0 = no match, 1 = 1 dice matched, 3 = all matched]:::")
print(test_filter)
print("TOTAL RESULT OF MATCHES::::")
print(test_result)

test <- function() throw_result(dice_throw(100000, 3), c(3, 4, 5))

print("TO RERUN use: throw_result(dice_throw(100000, 3), c(3, 4, 5)) or call test() ::")