
is_crayon_available <- require("crayon")
if (!is_crayon_available) {
  cat("\nInstalling crayon because pretty printing is nicer :-)\n")
  install.packages("crayon")
}
library(crayon)

#' myread.read_file
#' read csv/tsv file as data.frame
#' @author Ferhat Topcu
#' @param file_path the path string to the file
#' @param header is the first line the column definition?
#' @param separator defaults to tab separator \t
#'
#' @return table as data.frame
myread.read_file <- function(file_path, header = T, separator = "\t") {
  return(read.table(file_path, header = header, sep = separator, as.is = T))
}

#' myread.map_values
#' map values to expected sheet2 format
#' @author Ferhat Topcu
#' @param table_data data.frame returned from myread.read_file
#' @return table_data as transformed data.frame
myread.map_values <- function(table_data) {
  table_data$description <- NULL
  table_data$developerf <- as.factor(table_data$developer)
  table_data$filef <- as.factor(table_data$file)
  table_data$version <- as.factor(table_data$version)

  return(table_data)
}

#' csvdata
#' Takes a file_path string to a csv/tsv file and returns a data frame
#' @author Ferhat Topcu
#' @param file_path the path string to the file
#' @param header is the first line the column definition?
#' @param separator defaults to tab separator \t
#'
#' @return data.frame
myread.csvdata <- function(file_path, header = T, separator = "\t") {
  return(myread.map_values(myread.read_file(file_path, header, separator)))
}

#' myread.analyze_file
#' Analyzes a file and checks for structural validity of imported data
#' SIDEEFFECTS: Prints to the console before returning
#' @author Ferhat Topcu
#' @param file_path the path string to the file
#'
#' @return list(file = original_file,
#'  mapped = transformed_file, info = file_info)
myread.analyze_file <- function(file_path) {
  original_file <- myread.read_file(file_path)
  transformed_file <- myread.map_values(original_file)
  file_info <- file.info(file_path)

  cat(yellow("\n\n::: File: ", file_path))
  cat(
    red("\n::: Original File Size       : "),
    ((file_info$size)), blue(" bytes")
  )
  cat(
    red("\n::: Data points (original)   : "),
    ((nrow(original_file))), blue(" lines")
  )
  cat(
    red("\n::: Data points (mapped)     : "),
    ((nrow(transformed_file))), blue(" lines")
  )
  cat(
    red("\n::: File size to row ratio   : "),
    (trunc(file_info$size / nrow(transformed_file))),
    blue(" bytes per line on avg.")
  )
  cat(
    red("\n::: Table columns (original) : "),
    dimnames(original_file)[[2]]
  )
  cat(
    red("\n::: Table columns (mapped)   : "),
    dimnames(transformed_file)[[2]]
  )
  cat(
    red("\n::: Column count is 8        : "),
    length(dimnames(transformed_file)[[2]])
  )
  cat(
    red("\n::: description is NULL      : "),
    !("description" %in% dimnames(transformed_file)[[2]])
  )
  cat(
    red("\n::: $developer is string     : "),
    mode(transformed_file$developer) == "character"
  )
  cat(
    red("\n::: $developerf is factor    : "),
    mode(transformed_file$developerf) == "numeric"
  )
  cat(
    red("\n::: $file is string          : "),
    mode(transformed_file$file) == "character"
  )
  cat(
    red("\n::: $filef is factor         : "),
    mode(transformed_file$filef) == "numeric"
  )
  cat("\n")

  return(list(
    file = original_file,
    mapped = transformed_file,
    info = file_info
  ))
}

#' myread.test (2-1 d)
#' private function to test functionality of myread
#' @author Ferhat Topcu
myread.test <- function(zile = "src/sheet2/zile.tsv",
                        jikes = "src/sheet2/jikes.tsv",
                        junit = "src/sheet2/junit.tsv",
                        junit20 = "src/sheet2/junit20.tsv",
                        smry = T) {
  cat(cyan("Running tests for files: "))
  zl <- myread.analyze_file(zile)
  if (smry) {
    cat(red("\n::: Summary         : \n"))
    print(summary(zl$mapped))
  }
  jk <- myread.analyze_file(jikes)
  if (smry) {
    cat(red("\n::: Summary         : \n"))
    print(summary(jk$mapped))
  }
  ju <- myread.analyze_file(junit)
  if (smry) {
    cat(red("\n::: Summary         : \n"))
    print(summary(ju$mapped))
  }
  ju20 <- myread.analyze_file(junit20)
  if (smry) {
    cat(red("\n::: Summary         : \n"))
    print(summary(ju20$mapped))
  }
  cat(cyan("\033[F\033[F\033[F\033[FTests done.\n"))
}

#' developer.count
#' @param tdata tabular data.frame extracted from myread.csvdata
#' @return developer_count as integer
developer.count <- function(tdata) length(levels(tdata$developerf))

#' developer.busy
#' @param tdata tabular data.frame extracted from myread.csvdata
#' @return sorted table of up to 5 most active devs
developer.busy <- function(tdata) {
  devs <- sort(table(tdata$developerf), decreasing = T)

  return(devs[1:5])
}

#' developer.changedfiles
#' @param tdata tabular data.frame extracted from myread.csvdata
#' @return sorted table of dev to total file participation in %
developer.changedfiles <- function(tdata) {
  files <- tdata$filef ## dateien
  total_files <- length(levels(files)) ## anzahl dateien insgesamt
  devs <- tdata$developerf ## entwickler
  ## frequency tabelle ROW -> anzahl commits pro datei pro entwickler
  ## und die COLS -> dateien
  dev_table <- table(devs, files)

  return(sort(apply(dev_table, 1, FUN = function(x) {
    trunc(length(x[x > 0]) / total_files * 100)
  }), decreasing = T))
}

#' developer.test (2-2)
#' private function to test functionality of developer
#' @author Ferhat Topcu
developer.test <- function(zile = myread.csvdata("src/sheet2/zile.tsv"),
                           jikes = myread.csvdata("src/sheet2/jikes.tsv"),
                           junit = myread.csvdata("src/sheet2/junit.tsv"),
                           junit20 = myread.csvdata("src/sheet2/junit20.tsv"),
                           smry = T) {
  cat(cyan("Running developer tests for files: "))
  cat(yellow("\n\n::: File: ", "zile.tsv"))
  cat(red("\n::: Amount of devs       : "), developer.count(zile))
  cat(red("\n::: Top devs (in commits): \n"))
  print(developer.busy(zile))
  cat(red("\n::: Dev reach (in %)     : \n"))
  print(developer.changedfiles(zile))

  cat(yellow("\n\n::: File: ", "jikes.tsv"))
  cat(red("\n::: Amount of devs       : "), developer.count(jikes))
  cat(red("\n::: Top devs (in commits): \n"))
  print(developer.busy(jikes))
  cat(red("\n::: Dev reach (in %)     : \n"))
  print(developer.changedfiles(jikes))

  cat(yellow("\n\n::: File: ", "junit.tsv"))
  cat(red("\n::: Amount of devs       : "), developer.count(junit))
  cat(red("\n::: Top devs (in commits): \n"))
  print(developer.busy(junit))
  cat(red("\n::: Dev reach (in %)     : \n"))
  print(developer.changedfiles(junit))

  cat(yellow("\n\n::: File: ", "junit20.tsv"))
  cat(red("\n::: Amount of devs       : "), developer.count(junit20))
  cat(red("\n::: Top devs (in commits): \n"))
  print(developer.busy(junit20))
  cat(red("\n::: Dev reach (in %)     : \n"))
  print(developer.changedfiles(junit20))

  cat(cyan("\nTests done.\n"))
}

main <- function() {
  myread.test()
  cat("\n\n\n")
  developer.test()
}

main()