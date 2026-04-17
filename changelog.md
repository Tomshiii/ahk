# <> Release 2.17.0.3 - Hotfix

Release v2.17.0.2 was originally going to be the final patch before a massive rewrite to the UIA code, but I thought given that I have since fixed another memory leak issue it would be a bit insisidious for me to not backpatch that.  

As a reminder;  
> This release acts as the final patch before my repo moves to potentially requiring `Premiere v26.2+`  
> Supporting newer versions of Premiere will require some hefty rewrites to a lot of the UIA code and as such will **require** me to either bump the minimum version required for this repo, or it will be expected that the experience gathering UIA information will be somewhat regressed.

So in that regard;

> [!Caution]
> This release is **NOT** compatible with Premiere v26.2+. You may experience large slowdown attempting to use these functions on this version (and beyond) of Premiere. Please wait for an update to address this issue in the future. Track updates here <sup>[[1]](<https://github.com/Tomshiii/ahk/tree/prem-26.2-UIA>) [[2]](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=161573677>)</sup>
***

## Functions
- ✅ Fixed additional memory leak with functions that use `ShinsImageScanClass`
