This script is a vital part of my repo.
It handles generating a directory `SymLink` in `A_MyDocuments \AutoHotkey\` that links back to `..\lib\`, this allows all my scripts to easily reference lib/function files without needing to worry about directory locations.

This script is optionally run during the installation process of a release and should only be done during this time if you're extracting the release in it's final destination. Otherwise, if you choose not to do so, or you move my repo to another location, you can rerun this script to regenerate the SymLink.

**note: this script will require elevation as `cmd` needs to be run as admin to create a symlink*