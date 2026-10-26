for (file in files) {
  parts <- strsplit(file, "_")[[1]]
  condition <- parts[2]
  read <- sub("\\.fastq$", "", parts[4])
  
  dest_dir <- file.path("sorted_R", condition, read)
  
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  
  file.copy(file.path("raw", file),
            file.path(dest_dir, file))
}