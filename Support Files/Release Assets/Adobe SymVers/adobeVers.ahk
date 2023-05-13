/**
 * Values of adobe versions that share their images with each other.
 * Versions being listed here do NOT ensure they are completely compatible with my scripts, I do not have the manpower to extensively test version I do not use consistently
 * @param firstvalue is the NEW version
 * @param secondvalue is the version it's copying (so the ACTUAL folder)
 */
class adobeVers {
    Premiere := Map(
        "v23.0",    "v22.3.1",
        "v23.1",    "v22.3.1",
        "v23.2",    "v22.3.1",
        "v23.3",    "v22.3.1",
        "v23.4",    "v22.3.1",
    )
    AE := Map(
        "v23.0",    "v22.6",
        "v23.1",    "v22.6",
        "v23.2",    "v22.6",
        "v23.2.1",  "v22.6",
        "v23.3",  "v22.6",
        "v23.4",  "v22.6",
    )
    PS := Map(
        "v24.0.1",  "v24.3",
        "v24.1",    "v24.3",
        "v24.1.1",  "v24.3",
        "v24.2",    "v24.3",
        "v24.2.1",  "v24.3",
        "v24.4.1",  "v24.3",
    )

    static maps := [this().Premiere, this().AE, this().PS]
    static which := ["Premiere", "AE", "Photoshop"]
}