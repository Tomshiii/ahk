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

    var5 := "huh"
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

;// initialising a class allows you to access any method

/* tester  := test2()         ;// initialises the base class
tester2 := test2.test3()   ;// initialises the nested class
msgbox tester.var          ;// works - includes "this."
msgbox tester.var2         ;// doesn't work
msgbox tester.var3         ;// works
MsgBox tester2.var4        ;// works
MsgBox tester.var4         ;// works
MsgBox tester.tick()       ;// calls both tick()s
tester.call()              ;// works
tester.call2()             ;// works */


;// let static methods access non static methods using this().
Class test3 {
    static __notSoHidden() {
        MsgBox("oh no you found me again")
    }
    __superHidden() {
        MsgBox("you'll never find me")
        ; this.__notSoHidden()   ;// doesn't work
        ; this.()__notSoHidden() ;// doesn't work
        ;// nonstatic methods can't call back to a static method with `this`
        test3.__notSoHidden()   ;// it has to be called like this
    }
    __hidden() {
        MsgBox("you found me")
        this.__superHidden()    ;// non static methods call other non static without `()`
    }

    static caller() {
        this().__hidden()       ;// static methods call non static methods with `this().`
    }
}
; test3.caller() ;// calls `caller()` which calls `__hidden()` which calles `__superHidden()`

Class test4 {
    __Init() {

    }
    /* __New() {
        this.var := "hell0"
        this.__Method("test")
    } */

    /* __Method(words) {
        MsgBox(this.var)
    } */
    otherthing => "duh"
    ; words := this.__Method("test")
    check := true
}

ver := test4()
msgbox ver.check
; msgbox ver.words