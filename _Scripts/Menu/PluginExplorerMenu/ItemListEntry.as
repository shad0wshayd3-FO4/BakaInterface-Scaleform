package Menu.PluginExplorerMenu
{
    import flash.text.TextField;
    import Shared.AS3.BSScrollingScrollListEntry;
    import Shared.GlobalFunc;

    public class ItemListEntry extends BSScrollingScrollListEntry
    {
        public var FormID_tf:TextField;

        public function ItemListEntry()
        {
            super();
        }

        override public function SetEntryText(a_object:Object, a_textOption:String):*
        {
            super.SetEntryText(a_object, a_textOption);

            GlobalFunc.SetText(this.FormID_tf, a_object.textFormID, false);
            this.FormID_tf.textColor = !!this.selected ? 0x000000 : 0xFFFFFF;
        }
    }
}
