# <> Release 2.14.x - 

## Functions

`ytdlp {`
- Fixed `download()` failing to increment filenames past `1`
- `download()` will now check the window filepath before reactivating it, ensuring it doesn't activate a random window simply because it shares the same folder name