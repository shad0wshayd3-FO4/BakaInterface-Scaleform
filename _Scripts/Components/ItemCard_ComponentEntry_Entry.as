package Components
{
    import Shared.AS3.BSScrollingListEntry;
    import flash.display.MovieClip;
    import flash.text.TextLineMetrics;

    public class ItemCard_ComponentEntry_Entry extends BSScrollingListEntry
    {
        public static const ICON_SPACING:Number = 15;

        public var FavIcon_mc:MovieClip;

        public function ItemCard_ComponentEntry_Entry()
        {
            super();
        }

        override public function SetEntryText(param1:Object, param2:String):*
        {
            var _loc3_:TextLineMetrics = null;
            var _loc4_:Number = NaN;
            super.SetEntryText(param1, param2);
            if (param1.count != 1 && param1.count != undefined)
            {
                textField.appendText(" (" + param1.count + ")");
            }
            if (this.FavIcon_mc != null)
            {
                _loc3_ = textField.getLineMetrics(0);
                _loc4_ = textField.x + _loc3_.x + _loc3_.width + this.FavIcon_mc.width / 2 + ICON_SPACING;
                this.FavIcon_mc.x = _loc4_;
                this.FavIcon_mc.visible = param1.favorite > 0 || param1.taggedForSearch;
            }
        }
    }
}
