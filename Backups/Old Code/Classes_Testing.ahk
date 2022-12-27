;// this is code I used to test classes while trying to refactor `checklist.ahk` to use a timer class

class test {
    __Init() {
        ;// runs when test 2 is initialised
        this.var := 20
    }
    var3 := "duh"            ;// works when outside of the init
    call() {
        MsgBox("test1")
    }

    tick() {
        var := "hello there"
        MsgBox(var)
    }
}

class test2 extends test {
    __Init() {
        ;// calls test 1 __init()
        super.__Init()

        ;// runs when test 2 is initialised
        ; ...
        var2 := 30          ;// can't be put here like this, missing "this."
        ; MsgBox(this.var3) ;// this works
    }

    call2() {
        ; super.call() ;// calls call() in base calss
        msgbox "test2"
    }

    class test3 {
        var4 := "hello"
    }

    tick() {
        var := "goodbye"
        MsgBox(var)
    }

}

tester  := test2()         ;// initialises the base class
tester2 := test2.test3()   ;// initialises the nested class
msgbox tester.var          ;// works - includes "this."
msgbox tester.var2         ;// doesn't work
msgbox tester.var3         ;// works
MsgBox tester2.var4        ;// works
MsgBox tester.var4         ;// works
MsgBox tester.tick()       ;// calls both tick()s
; tester.call()            ;// works
; tester.call2()           ;// works




;// initialising a class allows you to access any method