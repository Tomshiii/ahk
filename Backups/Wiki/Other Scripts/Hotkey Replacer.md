This script is not one you will need during usual interactions with my scripts and is instead designed to help ease you through transitioning to a new release.

I'm under no assumption that you'll want to keep my hotkeys for yourself, quite the opposite, I more than expect you to change them all up. This script is designed to go through `My Scripts.ahk` & `KSA.ini` and replace my default values with the ones you've replaced them with in your own instances of my scripts!

It does this by searching for `;Hotkey;` tags in `My Scripts.ahk` and `]` in `KSA.ini`. From there it does some string manipulation, generates some `.ini` lists for both the default tags & the user tags, cross references them against each other and replaces the two!

This script will not replace new tags you add yourself and can't replace any custom code you've added yourself.

![image](https://user-images.githubusercontent.com/53557479/199233527-a0be043e-d3f4-4334-a4b3-1c4a7512d138.png)

**`Hotkey Replacer.ahk` as of v2.6.1pre2*