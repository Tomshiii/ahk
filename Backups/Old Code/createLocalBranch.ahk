#Requires AutoHotkey v2.0
#SingleInstance Force

;// ai slop created method of generating a local only branch

;// Create `\.git\hooks\pre-push` with no file extension;
/**
#!/bin/sh
# Refuse to push any branch under local/
while read local_ref local_sha remote_ref remote_sha; do
  case "$local_ref" in
    refs/heads/local/*)
      echo "pre-push: BLOCKED - '$local_ref' is a local-only branch." >&2
      exit 1
      ;;
  esac
done
exit 0
*/

repo   := "E:\Github\ahk"
prefix := "local/"

NewLocalBranch()

NewLocalBranch() {
    global prefix

    ib := InputBox("Branch name (prefix '" prefix "' is added automatically):", "New local branch")
    if ib.Result != "OK" || Trim(ib.Value) = ""
        return
    name := prefix . RegExReplace(Trim(ib.Value), "\s+", "-")

    ib2 := InputBox("Base branch or commit:", "Base", , "main")
    if ib2.Result != "OK"
        return
    base := Trim(ib2.Value) != "" ? Trim(ib2.Value) : "main"

    ; --no-track: never set an upstream, even if base is origin/something
    r := Git('switch -c "' name '" --no-track "' base '"')
    if r.code {
        MsgBox("Failed:`n`n" r.out, "git", "Iconx")
        return
    }

    ; Belt and braces: a plain "git push" on this branch errors out too
    Git('config "branch.' name '.pushRemote" none')

    MsgBox("Created and switched to '" name "' from '" base "'.", "git", "Iconi T3")
}

Git(args) {
    global repo
    sh   := ComObject("WScript.Shell")
    exec := sh.Exec(A_ComSpec ' /c git -C "' repo '" ' args)
    out  := exec.StdOut.ReadAll() . exec.StdErr.ReadAll()
    return {code: exec.ExitCode, out: out}
}