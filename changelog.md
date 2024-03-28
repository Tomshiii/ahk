# <> Release 2.14.x - 

## > Functions
- Fixed `premUIA_Values(false).__setNewVal()` failing to override values under certain circumstances

`adobeVerOverride()`
- Will now only fire on a fresh start and **not** on a reload
- Will reload all active scripts if it changes a value