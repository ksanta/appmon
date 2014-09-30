
createOrEmptyDirectory <- function(dirname) {
        # Delete all existing files if they exist
        if(file.exists(dirname)) {
           files <- list(list.files(dirname, full.names=TRUE))
           do.call(file.remove,files)
        } else {
            dir.create(dirname)
        }
}