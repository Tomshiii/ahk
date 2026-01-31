

class Mutex {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.Handle :=
        proto.Options :=
        ''
        proto.Owned :=
        proto.Waiting :=
        0
    }
    /**
     * @class - An AHK wrapper around the
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexw mutex API}.
     *
     * @param {Mutex.Options|Object} [Options] - A {@link Mutex.Options} object, or an object with
     * zero or more options as property : value pairs.
     *
     * @param {Integer} [Options.DesiredAccess] - If `Options.DesiredAccess` is set with a nonzero
     * value, {@link Mutex.Prototype.Create} creates the mutex object using
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexexw CreateMutexExW}
     * instead of
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexw CreateMutexW}.
     *
     * To include multiple values, use bit-wise "or" ( | ), e.g. `0x00080000 | 0x00100000 | 0x00020000`.
     *
     * Valid access mask values are:
     * - DELETE - 0x00010000 - Required to delete the object.
     * - READ_CONTROL - 0x00020000 - Required to read information in the security descriptor for the
     * object, not including the information in the SACL.
     * - SYCHRONIZE - 0x00100000 - The right to use the object for synchronization. This enables a
     * thread to wait until the object is in the signaled state.
     * - WRITE_DAC - 0x00040000 - Required to modify the DACL in the security descriptor for the
     * object.
     * - WRITE_OWNER - 0x00080000 - Required to change the owner in the security descriptor for the
     * object.
     * - MUTEX_ALL_ACCESS - 0x1F0001 - All possible access rights for a mutex object. Use this right
     * only if your application requires access beyond that granted by the standard access rights.
     * Using this access right increases the possibility that your application must be run by an
     * Administrator.
     * {@link https://learn.microsoft.com/en-us/windows/win32/sync/synchronization-object-security-and-access-rights}.
     *
     * @param {Boolean} [Options.InitialOwner = false] - If true, when the mutex is created, the
     * calling thread is the initial owner of the mutex.
     *
     * @param {Buffer|Mutex_SecurityAttributes} [Options.MutexAttributes = 0] - Either a
     * {@link Mutex_SecurityAttributes} object, or a `Buffer` containing a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wtypesbase/ns-wtypesbase-security_attributes SECURITY_ATTRIBUTES}
     * structure. If `Options.MutexAttributes` is 0, the mutex is created with default security
     * attributes. "By default, the default DACL in the access token of a process allows access only
     * to the user represented by the access token."
     *
     * @param {String} [Options.Name] - The name of the mutex object.
     *
     * When creating a mutex object, the name must be unique across the system. If the name is
     * already in use, and the name is associated with an existing mutex object,
     * `CreateMutex` requests a handle to the existing mutex object instead of creating
     * a new object. If the name exists but is some other type of object, the function fails.
     *
     * <!-- Note: If you are reading this from the source file, the backslashes below are escaped so the
     * markdown renderer displays them correctly. Treat each backslash pair as a single backslash. -->
     *
     * To direct {@link Mutex.Prototype.__New} to generate a random name, set `Options.Name`
     * with any string that ends with a backslash optionally followed by a number representing the
     * number of characters to include in the name. Your code can begin the string with any valid
     * string to use as a prefix, and the random characters will be appended to the prefix. For
     * example, each of the following are valid for producing a random name:
     * - "\\" - generates a random name of 16 characters.
     * - "\\20" - generates a random name of 20 characters.
     * - "Global\\\\22" - generates a random name of 22 characters and appends it to "Global\\".
     * - "Local\\\\" - generates a random name of 16 characters and appends it to "Local\\".
     * - "Local\\MyAppName_\\" - generates a random name of 16 characters and appends it to
     *   "Local\\MyAppName_".
     * - "MyAppName\\14" - generates a random name of 14 characters and appends it to "MyAppName".
     * - "Global\\Ajmz(eOO\\10" - generates a random name of 10 characters and appends it to
     *   "Global\\Ajmz(eOO".
     *
     * The random characters fall between code points 33 - 91, inclusive. If your application requires
     * a different set of characters to be used, leave `Options.Name` unset and call
     * {@link Mutex.Prototype.SetName} before opening the mutex object.
     *
     * When {@link Mutex.Prototype.SetName} generates the random name, it overwrites the
     * value of the property "Name" on the options object. Accessing {@link Mutex.Prototype.Name}
     * will return the new name.
     *
     * Using a random name has the benefit of preventing a scenario where a bad-actor blocks your
     * application from functioning intentionally by preemptively creating an object with a name
     * known to be used by your application. It is also helpful for avoiding a scenario where
     * your application attempts to use the same name as another application coincidentally.
     *
     * @param {Boolean} [SkipOptions = false] - If true, `Options` must be set with a
     * {@link Mutex.Options} object. When true, {@link Mutex.Prototype.__New} does not
     * pass `Options` to {@link Mutex.Options.Prototype.__New}. Set this to true if using
     * an existing options object.
     */
    __New(Options?, SkipOptions := false) {
        if SkipOptions {
            this.Options := Options
        } else {
            options := this.Options := Mutex.Options(options ?? unset)
        }
        if options.Name {
            this.SetName(options.Name)
        }
        this.Waiting := this.Owned := 0
        this.Create()
    }
    /**
     * @description - Releases the mutex if necessary then calls `CloseHandle`.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle}
     *
     * @throws {OSError} - If `CloseHandle` returns zero.
     */
    Close() {
        if this.Handle {
            this.Release()
            if DllCall(g_kernel32_CloseHandle, 'ptr', this.Handle, 'int') {
                this.DeleteProp('Handle')
            } else {
                throw OSError()
            }
        }
    }
    /**
     * @description - If `Options.DesiredAccess` is set with a nonzero value,
     * {@link Mutex.Prototype.Create} creates the mutex object using
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexexw CreateMutexExW}
     * instead of
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexw CreateMutexW}.
     *
     * This sets property {@link Mutex#Handle}.
     *
     * @throws {OSError} - If either `CreateMutexW` or `CreateMutexExW` returns 0.
     */
    Create() {
        options := this.Options
        this.Owned := options.InitialOwner
        if options.DesiredAccess {
            if !(this.Handle := DllCall(
                g_kernel32_CreateMutexExW
              , 'ptr', options.MutexAttributes
              , 'str', options.Name
              , 'uint', options.InitialOwner
              , 'uint', options.DesiredAccess
              , 'int'
            )) {
                throw OSError()
            }
        } else {
            if !(this.Handle := DllCall(
                g_kernel32_CreateMutexW
              , 'ptr', options.MutexAttributes
              , 'int', options.InitialOwner
              , 'str', options.Name
              , 'int'
            )) {
                throw OSError()
            }
        }
    }
    /**
     * @description - Calls `ReleaseMutex` and sets `MutexObj.Owned := false` if successful.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-releasemutex}
     *
     * @throws {OSError} - If `ReleaseMutex` returns 0.
     */
    Release() {
        if this.Owned {
            this.Owned := 0
            if !DllCall(g_kernel32_ReleaseMutex, 'ptr', this.Handle, 'int') {
                throw OSError()
            }
        }
    }
    /**
     * @description - Sets the name of the mutex object, updating property
     * {@link Mutex.Prototype.Name}. If a mutex object is currently open, it will
     * need to be closed and a new one opened to reflect the change.
     *
     * See the description of option `Options.Name` in the parameter hint above
     * {@link Mutex.Prototype.__New} for more information about the mutex name.
     *
     * @param {String} Name - The name to associate with the mutex object. Set `Name`
     * with a string that ends with a backslash optionally followed by an integer representing
     * the number of characters to include in the randomized portion of the string. See the
     * description of option `Options.Name` in the parameter hint above
     * {@link Mutex.Prototype.__New} for more information.
     *
     * @param {String[]} [Characters] - If set, an array of strings that are used to generate the
     * randomized portion of the name.
     *
     * @returns {String} - The name.
     */
    SetName(Name, Characters?) {
        if RegExMatch(Name, 'S)\\(\d*)$', &match) {
            Name := SubStr(Name, 1, match.Pos - 1)
            if IsSet(Characters) {
                len := Characters.Length
                loop match[1] || 16 {
                    Name .= Characters[Random(1, len)]
                }
            } else {
                loop match[1] || 16 {
                    Name .= Chr(Random(33, 91))
                }
            }
        }
        return this.Options.Name := Name
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject WaitForSingleObject}.
     *
     * @param {Integer} [Timeout = 0] - The time-out interval, in milliseconds. If a nonzero value
     * is specified, the function waits until the object is signaled or the interval elapses. If
     * `Timeout` is zero, the function does not enter a wait state if the object is not signaled;
     * it always returns immediately. Note that the Windows API includes `INFINITE` as a valid input;
     * `INFINITE` is represented by the number `0xFFFFFFFF`.
     *
     * If `Timeout` is `0` and the object is not signaled (the mutex is currently owned by another
     * thread and is unavailable), then this function returns `WAIT_TIMEOUT` immediately. The calling
     * thread can use this information to decide if it should perform some other task in the meantime and
     * check if the object is available later. For example, to use a `Mutex` shared by two AHK
     * processes, you can call `SetTimer()` to repeatedly check if an object is available to perform
     * some task, and once the task is complete, to terminate the timer. This keeps the thread open
     * to performing other actions while it waits for the object to become available.
     *
     * @returns {Integer} - One of the following numbers:
     * - WAIT_ABANDONED (128) - The thread that owned the mutex was terminated before it released
     *   the mutex. `WAIT_ABANDONED` is a warning to the thread that now owns the mutex that there
     *   may be a problem with the data, and the data might need to be validated or checked for
     *   consistency. This depends entirely on the application and the context in which this occurs.
     * - WAIT_OBJECT_0 (0) - The state of the specified object is signaled.
     * - WAIT_TIMEOUT (258) - The time-out interval elapsed, and the object's state is nonsignaled.
     * - WAIT_FAILED (4294967295) - The function failed. Call `OSError`.
     *
     * @throws {Error} - "The mutex is already owned by this process."
     */
    Wait(Timeout := 0) {
        if this.Owned {
            throw Error('The mutex is already owned by this process.')
        }
        this.Waiting := 1
        switch result := DllCall(g_kernel32_WaitForSingleObject, 'ptr', this.Handle, 'uint', Timeout, 'uint') {
            case WAIT_ABANDONED, WAIT_OBJECT_0: this.Owned := 1
        }
        this.Waiting := 0
        return result
    }
    /**
     * @description - This function does the following:
     * - Sets {@link Mutex#Waiting} to 1.
     * - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject WaitForSingleObject}.
     * - After the wait function returns, sets {@link Mutex#Waiting} to 0.
     * - If the return value from the wait function is WAIT_OBJECT_0 or WAIT_ABANDONED, sets {@link Mutex#Owned} to 1.
     * - If the return value from the wait function is associated with an item in `CallbackMap`,
     *   calls the item, setting `OutCallbackResult` with the return value.
     * - Returns the return value from the wait function.
     *
     * Note that this does not call {@link Mutex.Prototype.Release} to release the mutex. Your code
     * must release the mutex.
     *
     * @param {Mutex.Map|Map} CallbackMap - A map object that associates the return values from the
     * wait function with a function to call. Though you are not required to use them, you may
     * choose to use {@link Mutex.Map}, {@link Mutex.Item} or {@link Mutex.ItemEx}.
     *
     * @param {Integer} [Timeout = 0] - The time-out interval, in milliseconds. If a nonzero value
     * is specified, the function waits until the object is signaled or the interval elapses. If
     * `Timeout` is zero, the function does not enter a wait state if the object is not signaled;
     * it always returns immediately. Note that the Windows API includes `INFINITE` as a valid input;
     * `INFINITE` is represented by the number `0xFFFFFFFF`.
     *
     * If `Timeout` is `0` and the object is not signaled (the mutex is currently owned by another
     * thread and is unavailable), then this function returns `WAIT_TIMEOUT` immediately. The calling
     * thread can use this information to decide if it should perform some other task in the meantime and
     * check if the object is available later. For example, to use a `Mutex` shared by two AHK
     * processes, you can call `SetTimer()` to repeatedly check if an object is available to perform
     * some task, and once the task is complete, to terminate the timer. This keeps the thread open
     * to performing other actions while it waits for the object to become available.
     *
     * @param {VarRef} [OutCallbackResult] - A variable that receives the return value from `Callback`.
     *
     * @returns {Integer} - One of the following numbers:
     * - WAIT_ABANDONED (128) - The thread that owned the mutex was terminated before it released
     *   the mutex. `WAIT_ABANDONED` is a warning to the thread that now owns the mutex that there
     *   may be a problem with the data, and the data might need to be validated or checked for
     *   consistency. This depends entirely on the application and the context in which this occurs.
     * - WAIT_OBJECT_0 (0) - The state of the specified object is signaled.
     * - WAIT_TIMEOUT (258) - The time-out interval elapsed, and the object's state is nonsignaled.
     * - WAIT_FAILED (4294967295) - The function failed. Call `OSError`.
     *
     * @throws {Error} - "The mutex is already owned by this process."
     */
    Wait2(CallbackMap, Timeout := 0, &OutCallbackResult?) {
        if this.Owned {
            throw Error('The mutex is already owned by this process.')
        }
        this.Waiting := 1
        switch result := DllCall(g_kernel32_WaitForSingleObject, 'ptr', this.Handle, 'uint', Timeout, 'uint') {
            case WAIT_ABANDONED, WAIT_OBJECT_0: this.Owned := 1
        }
        this.Waiting := 0
        if CallbackMap.Has(result) {
            OutCallbackResult := CallbackMap.Get(result)(this)
        }
        return result
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobjectex WaitForSingleObjectEx}.
     *
     * @param {Integer} [Timeout = 0] - The time-out interval, in milliseconds. If a nonzero value
     * is specified, the function waits until the object is signaled or the interval elapses. If
     * `Timeout` is zero, the function does not enter a wait state if the object is not signaled;
     * it always returns immediately. Note that the Windows API includes `INFINITE` as a valid input;
     * `INFINITE` is represented by the number `0xFFFFFFFF`.
     *
     * If `Timeout` is `0` and the object is not signaled (the mutex is currently owned by another
     * thread and is unavailable), then this function returns `WAIT_TIMEOUT` immediately. The calling
     * thread can use this information to decide if it should perform some other task in the meantime and
     * check if the object is available later. For example, to use a `Mutex` shared by two AHK
     * processes, you can call `SetTimer()` to repeatedly check if an object is available to perform
     * some task, and once the task is complete, to terminate the timer. This keeps the thread open
     * to performing other actions while it waits for the object to become available.
     *
     * @returns {Integer} - One of the following numbers:
     * - WAIT_ABANDONED (128) - The thread that owned the mutex was terminated before it released
     *   the mutex. `WAIT_ABANDONED` is a warning to the thread that now owns the mutex that there
     *   may be a problem with the data, and the data might need to be validated or checked for
     *   consistency. This depends entirely on the application and the context in which this occurs.
     * - WAIT_OBJECT_0 (0) - The state of the specified object is signaled.
     * - WAIT_TIMEOUT (258) - The time-out interval elapsed, and the object's state is nonsignaled.
     * - WAIT_FAILED (4294967295) - The function failed. Call `OSError`.
     * - WAIT_IO_COMPLETION (192) - The wait was ended by one or more user-mode asynchronous procedure
     *   calls (APC) queued to the thread.
     *
     * @throws {Error} - "The mutex is already owned by this process."
     */
    WaitEx(Timeout := 0, Alertable := false) {
        if this.Owned {
            throw Error('The mutex is already owned by this process.')
        }
        this.Waiting := 1
        switch result := DllCall(g_kernel32_WaitForSingleObjectEx, 'ptr', this.Handle, 'uint', Timeout, 'int', Alertable, 'uint') {
            case WAIT_ABANDONED, WAIT_OBJECT_0: this.Owned := 1
        }
        this.Waiting := 0
        return result
    }
    /**
     * @description - This function does the following:
     * - Sets {@link Mutex#Waiting} to 1.
     * - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobjectex WaitForSingleObjectEx}.
     * - After the wait function returns, sets {@link Mutex#Waiting} to 0.
     * - If the return value from the wait function is WAIT_OBJECT_0 or WAIT_ABANDONED, sets {@link Mutex#Owned} to 1.
     * - If the return value from the wait function is associated with an item in `CallbackMap`,
     *   calls the item, setting `OutCallbackResult` with the return value.
     * - Returns the return value from the wait function.
     *
     * Note that this does not call {@link Mutex.Prototype.Release} to release the mutex. Your code
     * must release the mutex.
     *
     * @param {Mutex.Map|Map} CallbackMap - A map object that associates the return values from the
     * wait function with a function to call. Though you are not required to use them, you may
     * choose to use {@link Mutex.Map}, {@link Mutex.Item} or {@link Mutex.ItemEx}.
     *
     * @param {Integer} [Timeout = 0] - The time-out interval, in milliseconds. If a nonzero value
     * is specified, the function waits until the object is signaled or the interval elapses. If
     * `Timeout` is zero, the function does not enter a wait state if the object is not signaled;
     * it always returns immediately. Note that the Windows API includes `INFINITE` as a valid input;
     * `INFINITE` is represented by the number `0xFFFFFFFF`.
     *
     * If `Timeout` is `0` and the object is not signaled (the mutex is currently owned by another
     * thread and is unavailable), then this function returns `WAIT_TIMEOUT` immediately. The calling
     * thread can use this information to decide if it should perform some other task in the meantime and
     * check if the object is available later. For example, to use a `Mutex` shared by two AHK
     * processes, you can call `SetTimer()` to repeatedly check if an object is available to perform
     * some task, and once the task is complete, to terminate the timer. This keeps the thread open
     * to performing other actions while it waits for the object to become available.
     *
     * @param {VarRef} [OutCallbackResult] - A variable that receives the return value from `Callback`.
     *
     * @returns {Integer} - One of the following numbers:
     * - WAIT_ABANDONED (128) - The thread that owned the mutex was terminated before it released
     *   the mutex. `WAIT_ABANDONED` is a warning to the thread that now owns the mutex that there
     *   may be a problem with the data, and the data might need to be validated or checked for
     *   consistency. This depends entirely on the application and the context in which this occurs.
     * - WAIT_OBJECT_0 (0) - The state of the specified object is signaled.
     * - WAIT_TIMEOUT (258) - The time-out interval elapsed, and the object's state is nonsignaled.
     * - WAIT_FAILED (4294967295) - The function failed. Call `OSError`.
     * - WAIT_IO_COMPLETION (192) - The wait was ended by one or more user-mode asynchronous procedure
     *   calls (APC) queued to the thread.
     *
     * @throws {Error} - "The mutex is already owned by this process."
     */
    WaitEx2(CallbackMap, Timeout := 0, Alertable := false, &OutCallbackResult?) {
        if this.Owned {
            throw Error('The mutex is already owned by this process.')
        }
        this.Waiting := 1
        switch result := DllCall(g_kernel32_WaitForSingleObjectEx, 'ptr', this.Handle, 'uint', Timeout, 'int', Alertable, 'uint') {
            case WAIT_ABANDONED, WAIT_OBJECT_0: this.Owned := 1
        }
        this.Waiting := 0
        if CallbackMap.Has(result) {
            OutCallbackResult := CallbackMap.Get(result)(this)
        }
        return result
    }
    __Delete() {
        this.Close()
    }

    /**
     * Gets or sets the name used when creating a mutex object. If your code sets the name,
     * and if a mutex object has already been created, your code will need to close the
     * current mutex object and re-open a new one to obtain a mutex object with the
     * name.
     *
     * See the description of `Options.Name` in the parameter hint above {@link Mutex.Prototype.__New}
     * for more information.
     *
     * @instance
     * @member {Mutex}
     * @type {String}
     */
    Name {
        Get => this.Options.Name
        Set => this.SetName(Value)
    }

    class Options {
        static __New() {
            this.DeleteProp('__New')
            Mutex_SetConstants()
            proto := this.Prototype
            proto.Name :=
            ''
            proto.DesiredAccess :=
            proto.InitialOwner :=
            proto.MutexAttributes :=
            0
        }
        __New(Options?) {
            if IsSet(Options) {
                for prop in Mutex.Options.Prototype.OwnProps() {
                    if HasProp(Options, prop) {
                        this.%prop% := Options.%prop%
                    }
                }
                if this.HasOwnProp('__Class') {
                    this.DeleteProp('__Class')
                }
            }
        }
    }

    class Map extends Map {
        /**
         * @class - A map object used to associate a function with a specific return value from
         * one of the wait functions. The items can be any `Func` or callable object. You can, but
         * are not required to, use the {@link Mutex.Item} or {@link Mutex.ItemEx} classes which
         * offer the benefit of providing a means for associating parameters with the functions, and
         * optionally cache the return value from the functions.
         *
         * @param {*} [Object_0] - The object to call when the wait function returns WAIT_OBJECT_0.
         *
         * @param {*} [Abandoned] - The object to call when the wait function returns WAIT_ABANDONED.
         *
         * @param {*} [Timeout] - The object to call when the wait function returns WAIT_TIMEOUT.
         *
         * @param {*} [Failed] - The object to call when the wait function returns WAIT_FAILED.
         *
         * @param {*} [IoCompletion] - The object to call when the wait function returns WAIT_IO_COMPLETION.
         */
        __New(Object_0?, Abandoned?, Timeout?, Failed?, IoCompletion?) {
            if IsSet(Object_0) {
                this.Set(WAIT_OBJECT_0, Object_0)
            }
            if IsSet(Abandoned) {
                this.Set(WAIT_ABANDONED, Abandoned)
            }
            if IsSet(Timeout) {
                this.Set(WAIT_TIMEOUT, Timeout)
            }
            if IsSet(Failed) {
                this.Set(WAIT_FAILED, Failed)
            }
            if IsSet(IoCompletion) {
                this.Set(WAIT_IO_COMPLETION, IoCompletion)
            }
        }
    }

    class Item {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.Params :=
            proto.Result :=
            ''
        }
        /**
         * @class - An item used to be used with {@link Mutex.Map}.
         *
         * @param {*} Callback - A `Func` or callable object.
         *
         * @param {*} [Params] - If set, parameters to pass to `Callback`.
         *
         * @param {Boolean} [UseVariadicOperator = true] - If true, and if `Params` is set, `Params`
         * is passed to `Callback` using the
         * {@link https://www.autohotkey.com/docs/v2/Functions.htm#Variadic variadic operator ( * )}.
         *
         * If false, and if `Params` is set, `Params` is passed to `Callback` as-is.
         *
         * If `Params` is unset, `UseVariadicOperator` is ignored.
         *
         * @param {Boolean} [CacheReturnValue = false] - If true, the return value is cached on
         * property {@link Mutex.Item#Result} and also returned by the function. If false, the return
         * value is just returned by the function.
         */
        __New(Callback, Params?, UseVariadicOperator := true, CacheReturnValue := false) {
            this.Callback := Callback
            this.SetParams(Params ?? unset, UseVariadicOperator, CacheReturnValue)
        }
        Call() {
            return this.Callback.Call(this.Params*)
        }
        /**
         * @description - Sets the {@link Mutex.Item#Params} property and the
         * {@link Mutex.Item#Call} method. To call the callback without any params, call this
         * method leaving `Params` unset.
         *
         * @param {*} [Params] - If set, parameters to pass to `Callback`.
         *
         * @param {Boolean} [UseVariadicOperator = true] - If true, and if `Params` is set, `Params`
         * is passed to `Callback` using the
         * {@link https://www.autohotkey.com/docs/v2/Functions.htm#Variadic variadic operator ( * )}.
         *
         * If false, and if `Params` is set, `Params` is passed to `Callback` as-is.
         *
         * If `Params` is unset, `UseVariadicOperator` is ignored.
         *
         * @param {Boolean} [CacheReturnValue = false] - If true, the return value is cached on
         * property {@link Mutex.Item#Result} and also returned by the function. If false, the return
         * value is just returned by the function.
         */
        SetParams(Params?, UseVariadicOperator := true, CacheReturnValue := false) {
            if IsSet(Params) {
                if UseVariadicOperator {
                    if CacheReturnValue {
                        this.DefineProp('Call', Mutex.Item.Prototype.GetOwnPropDesc('__Call_Cache_Variadic'))
                    } else if this.HasOwnProp('Call') {
                        this.DeleteProp('Call')
                    }
                } else if CacheReturnValue {
                    this.DefineProp('Call', Mutex.Item.Prototype.GetOwnPropDesc('__Call_Cache_NoVariadic'))
                } else {
                    this.DefineProp('Call', Mutex.Item.Prototype.GetOwnPropDesc('__Call_NoVariadic'))
                }
                this.Params := Params
            } else if CacheReturnValue {
                this.DefineProp('Call', Mutex.Item.Prototype.GetOwnPropDesc('__Call_Cache_NoParams'))
            } else {
                this.DefineProp('Call', Mutex.Item.Prototype.GetOwnPropDesc('__Call_NoParams'))
            }
        }
        __Call_Cache_NoParams() {
            return this.Result := this.Callback.Call()
        }
        __Call_Cache_NoVariadic() {
            return this.Result := this.Callback.Call(this.Params)
        }
        __Call_Cache_Variadic() {
            return this.Result := this.Callback.Call(this.Params*)
        }
        __Call_NoParams() {
            return this.Callback.Call()
        }
        __Call_NoVariadic() {
            return this.Callback.Call(this.Params)
        }
    }

    class ItemEx extends Array {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.Params :=
            ''
        }
        /**
         * @class - An item used to be used with {@link Mutex.Map}. This is an array object that
         * stores the callback result values as an object with two properties, { Value, Time }.
         * "Value" is the return value. "Time" is set with `A_Now` after the callback returns.
         *
         * @param {*} Callback - A `Func` or callable object.
         *
         * @param {*} [Params] - If set, parameters to pass to `Callback`.
         *
         * @param {Boolean} [UseVariadicOperator = true] - If true, and if `Params` is set, `Params`
         * is passed to `Callback` using the
         * {@link https://www.autohotkey.com/docs/v2/Functions.htm#Variadic variadic operator ( * )}.
         *
         * If false, and if `Params` is set, `Params` is passed to `Callback` as-is.
         *
         * If `Params` is unset, `UseVariadicOperator` is ignored.
         */
        __New(Callback, Params?, UseVariadicOperator := true) {
            this.Callback := Callback
            this.SetParams(Params ?? unset, UseVariadicOperator)
        }
        Call() {
            this.Push({ Value: this.Callback.Call(this.Params*), Time: A_Now })
            return this[-1].Value
        }
        Clear() {
            this.Length := 0
        }
        /**
         * @description - Sets the {@link Mutex.Item#Params} property and the
         * {@link Mutex.Item#Call} method. To call the callback without any params, call this
         * method leaving `Params` unset.
         *
         * @param {*} [Params] - If set, parameters to pass to `Callback`.
         *
         * @param {Boolean} [UseVariadicOperator = true] - If true, and if `Params` is set, `Params`
         * is passed to `Callback` using the
         * {@link https://www.autohotkey.com/docs/v2/Functions.htm#Variadic variadic operator ( * )}.
         *
         * If false, and if `Params` is set, `Params` is passed to `Callback` as-is.
         *
         * If `Params` is unset, `UseVariadicOperator` is ignored.
         */
        SetParams(Params?, UseVariadicOperator := true) {
            if IsSet(Params) {
                if UseVariadicOperator {
                    if this.Call.Name != Mutex.ItemEx.Prototype.Call.Name {
                        this.DeleteProp('Call')
                    }
                } else {
                    this.DefineProp('Call', Mutex.ItemEx.Prototype.GetOwnPropDesc('__Call_NoVariadic'))
                }
                this.Params := Params
            } else {
                this.DefineProp('Call', Mutex.ItemEx.Prototype.GetOwnPropDesc('__Call_NoParams'))
            }
        }
        __Call_NoVariadic() {
            this.Push({ Value: this.Callback.Call(this.Params), Time: A_Now })
            return this[-1].Value
        }
        __Call_NoParams() {
            this.Push({ Value: this.Callback.Call(), Time: A_Now })
            return this[-1].Value
        }
    }
}

class Mutex_SecurityAttributes {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type        Symbol                  Offset               Padding
        A_PtrSize + ; DWORD     nLength                 0                    +4 on x64 only
        A_PtrSize + ; LPVOID    lpSecurityDescriptor    0 + A_PtrSize * 1
        A_PtrSize   ; BOOL      bInheritHandle          0 + A_PtrSize * 2    +4 on x64 only
        proto.offset_nLength               := 0
        proto.offset_lpSecurityDescriptor  := 0 + A_PtrSize * 1
        proto.offset_bInheritHandle        := 0 + A_PtrSize * 2
    }
    __New(nLength?, lpSecurityDescriptor?, bInheritHandle?) {
        this.Buffer := Buffer(this.cbSizeInstance)
        if IsSet(nLength) {
            this.nLength := nLength
        }
        if IsSet(lpSecurityDescriptor) {
            this.lpSecurityDescriptor := lpSecurityDescriptor
        }
        if IsSet(bInheritHandle) {
            this.bInheritHandle := bInheritHandle
        }
    }
    nLength {
        Get => NumGet(this.Buffer, this.offset_nLength, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_nLength)
        }
    }
    lpSecurityDescriptor {
        Get => NumGet(this.Buffer, this.offset_lpSecurityDescriptor, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lpSecurityDescriptor)
        }
    }
    bInheritHandle {
        Get => NumGet(this.Buffer, this.offset_bInheritHandle, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_bInheritHandle)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}


Mutex_SetConstants(force := false) {
    global
    if IsSet(Mutex_constants_set) && !force {
        return
    }

    local hMod := DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr')
    ; https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
    g_kernel32_CloseHandle := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'CloseHandle', 'ptr')
    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexw
    g_kernel32_CreateMutexW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'CreateMutexW', 'ptr')
    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexexw
    g_kernel32_CreateMutexExW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'CreateMutexExW', 'ptr')
    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-releasemutex
    g_kernel32_ReleaseMutex := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'ReleaseMutex', 'ptr')
    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject
    g_kernel32_WaitForSingleObject := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'WaitForSingleObject', 'ptr')
    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobjectex
    g_kernel32_WaitForSingleObjectEx := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'WaitForSingleObjectEx', 'ptr')


    ; https://learn.microsoft.com/en-us/windows/win32/sync/synchronization-object-security-and-access-rights

	; The following table lists the standard access rights used by all objects.

    ; Required to delete the object.
    DELETE := 0x00010000

    ; Required to read information in the security descriptor for the object, not including the
	; information in the SACL. To read or write the SACL, you must request the ACCESS_SYSTEM_SECURITY
	; access right. For more information, see SACL Access Right.
    READ_CONTROL := 0x00020000

    ; The right to use the object for synchronization. This enables a thread to wait until the object
	; is in the signaled state.
    SYNCHRONIZE := 0x00100000

    ; Required to modify the DACL in the security descriptor for the object.
    WRITE_DAC := 0x00040000

    ; Required to change the owner in the security descriptor for the object.
    WRITE_OWNER := 0x00080000

	; The following table lists the object-specific access rights for event objects. These rights are
	; supported in addition to the standard access rights.

    ; All possible access rights for an event object. Use this right only if your application requires
	; access beyond that granted by the standard access rights and EVENT_MODIFY_STATE. Using this access
	; right increases the possibility that your application must be run by an Administrator.
    EVENT_ALL_ACCESS := 0x1F0003

    ; Modify state access, which is required for the SetEvent, ResetEvent and PulseEvent functions.
    EVENT_MODIFY_STATE := 0x0002

	; The following table lists the object-specific access rights for mutex objects. These rights
	; are supported in addition to the standard access rights.

    ; All possible access rights for a mutex object. Use this right only if your application requires
	; access beyond that granted by the standard access rights. Using this access right increases the possibility that your application must be run by an Administrator.
    MUTEX_ALL_ACCESS := 0x1F0001

    ; Reserved for future use.
    MUTEX_MODIFY_STATE := 0x0001

	; The following table lists the object-specific access rights for semaphore objects. These rights
	; are supported in addition to the standard access rights.

    ; All possible access rights for a semaphore object. Use this right only if your application
	; requires access beyond that granted by the standard access rights and SEMAPHORE_MODIFY_STATE.
	; Using this access right increases the possibility that your application must be run by an Administrator.
    SEMAPHORE_ALL_ACCESS := 0x1F0003

    ; Modify state access, which is required for the ReleaseSemaphore function.
    SEMAPHORE_MODIFY_STATE := 0x0002

	; The following table lists the object-specific access rights for waitable timer objects.
	; These rights are supported in addition to the standard access rights.

    ; All possible access rights for a waitable timer object. Use this right only if your application
	; requires access beyond that granted by the standard access rights and TIMER_MODIFY_STATE. Using
	; this access right increases the possibility that your application must be run by an Administrator.
    TIMER_ALL_ACCESS := 0x1F0003

    ; Modify state access, which is required for the SetWaitableTimer and CancelWaitableTimer functions.
    TIMER_MODIFY_STATE := 0x0002

    ; Reserved for future use.
    TIMER_QUERY_STATE := 0x0001

    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexexa

    ; The object creator is the initial owner of the mutex.
    CREATE_MUTEX_INITIAL_OWNER := 0x00000001

    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject

    ; The specified object is a mutex object that was not released by the thread that owned the mutex
    ; object before the owning thread terminated. Ownership of the mutex object is granted to the
    ; calling thread and the mutex state is set to nonsignaled.
    ; If the mutex was protecting persistent state information, you should check it for consistency.
    WAIT_ABANDONED := 0x00000080

    ; The state of the specified object is signaled.
    WAIT_OBJECT_0 := 0x00000000

    ; The time-out interval elapsed, and the object's state is nonsignaled.
    WAIT_TIMEOUT := 0x00000102

    ; The function has failed. To get extended error information, call GetLastError.
    WAIT_FAILED := 0xFFFFFFFF

    ; https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobjectex

    ; The wait was ended by one or more user-mode asynchronous procedure calls (APC) queued to the thread.
    WAIT_IO_COMPLETION := 0x000000C0

    Mutex_constants_set := true
}
