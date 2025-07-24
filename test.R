# test.R
get_file_path <- function() {
  frame <- sys.frame(1)
  file_path <- attr(frame, "srcfile")$filename
  return(file_path)
}

print(get_file_path())