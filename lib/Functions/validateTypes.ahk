; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\Mip.ahk
; }

/**
 * A function to more quickly validate the types of all paramaterrs
 * @param {Array} [types] an array (in order) of all expected parameter types (as reported by `Type()`). The value of each array index should either be the `string` representation of what ahk see's the type as, or an array of `string` representations if a parameter may be multiple types.
 * @param {Any|Varadic} [values] all function paramaters you wish to check in the same order you listed them in `types`
 */
validateTypes(types, values*) {
    for i, expectedType in types {
        if types.Length != values.Length
            throw MethodError("Incorrect number of paramaters passed to function.", -1)

        switch Type(expectedType) {
            case "String":
                actualType := Type(values[i])
                if actualType != expectedType {
                    throw TypeError("Incorrect Type in Parameter #" i, -1,
                        "Expected: " StrTitle(expectedType) ", received: " actualType)
                }
            case "Array":
                doesEqual := false
                actualType := Mip()
                ErrorString := ""
                for index, value in expectedType {
                    actualType.Set(value, true)
                    ErrorString .= (index != expectedType.Length) ? StrTitle(value) " | " : StrTitle(value)
                }
                for v2 in expectedType {
                    if actualType.has(Type(values[i])) {
                        doesEqual := true
                        break
                    }
                }
                if doesEqual = true
                    continue
                throw TypeError("Incorrect Type in Parameter #" i, -1,
                        "Expected: " ErrorString ", received: " Type(values[i]))
        }
    }
}