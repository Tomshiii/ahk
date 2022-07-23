# <> Release 2.4.2.x

# > Functions
- `updateChecker()` will now attempt to download `.exe` release first, if not found will attempt a `.zip` and if that fails inform the user and back out. This is to replace the old behaviour of just downloading a dud file