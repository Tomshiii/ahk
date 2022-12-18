/**
 * This class is to provide a basic template for all GUIs I create to maintain a consistent theme
 *
 * @param FontSize allows you to pass in a custom default GUI font size. Defaults to 11, can be omitted
 * @param FontWeight allows you to pass in a custom default GUI font weight. Defaults to 11, can be omitted
 * @param options? allows you to pass in all GUI options that you would normally pass to a GUI. Can be omitted
 * @param title allows you to pass in a title for the GUI. Can be omitted
 */
class tomshiBasic extends Gui {
    __New(FontSize := 11, FontWeight := 500, options?, title:="") {
        super.__new(options?, title, this)
        this.BackColor := 0xF0F0F0
        this.SetFont("S" FontSize " W" FontWeight) ;Sets the size of the font
    }
}