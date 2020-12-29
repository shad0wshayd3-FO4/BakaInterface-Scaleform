package Menu.ContainerMenu
{
    import Shared.AS3.BSScrollingListEntry;
    import Shared.GlobalFunc;
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;

    public class ItemListEntry extends BSScrollingListEntry
    {
        public var LeftIcon_mc:MovieClip;
        public var FavoriteIcon_mc:MovieClip;
        public var LegendaryIcon_mc:MovieClip;
        public var TaggedForSearchIcon_mc:MovieClip;

        private var BaseTextFieldWidth;

        public function ItemListEntry()
        {
            super();
            this.BaseTextFieldWidth = textField.width;
        }

        override public function SetEntryText(aEntryObject:Object, astrTextOption:String):*
        {
            this.TaggedForSearchIcon_mc.visible = aEntryObject.taggedForSearch == true;
            this.FavoriteIcon_mc.visible = aEntryObject.favorite > 0;
            this.LegendaryIcon_mc.visible = aEntryObject.isLegendary == true;
            var textFieldWidthDelta:* = 0;
            if (this.FavoriteIcon_mc.visible && this.TaggedForSearchIcon_mc.visible)
            {
                textFieldWidthDelta = textFieldWidthDelta + (this.FavoriteIcon_mc.width / 2 + 10);
            }
            if (this.LegendaryIcon_mc.visible && this.FavoriteIcon_mc.visible)
            {
                textFieldWidthDelta = textFieldWidthDelta + (this.LegendaryIcon_mc.width / 2 + 10);
            }
            textField.width = this.BaseTextFieldWidth - textFieldWidthDelta;
            super.SetEntryText(aEntryObject, astrTextOption);

            var barterCount:int = 0;
            if (aEntryObject.barterCount != undefined)
            {
                barterCount = aEntryObject.barterCount;
            }

            var displayCount:int = aEntryObject.count - barterCount;
            GlobalFunc.SetText(textField, textField.text, false, false, true);
            if (displayCount != 1)
            {
                textField.appendText(" (" + displayCount + ")");
            }
            GlobalFunc.SetText(textField, textField.text, false);

            this.SetColorTransform(this.LeftIcon_mc, this.selected);
            this.SetColorTransform(this.FavoriteIcon_mc, this.selected);
            this.SetColorTransform(this.TaggedForSearchIcon_mc, this.selected);
            this.SetColorTransform(this.LegendaryIcon_mc, this.selected);

            this.LeftIcon_mc.EquipIcon_mc.visible = aEntryObject.equipState != 0;
            if (this.LeftIcon_mc.BarterIcon_mc != undefined)
            {
                this.LeftIcon_mc.BarterIcon_mc.visible = barterCount < 0;
            }

            this.TaggedForSearchIcon_mc.x = this.textField.getLineMetrics(0).width + this.textField.x + 10;
            this.LegendaryIcon_mc.x = !!this.TaggedForSearchIcon_mc.visible ? Number(this.TaggedForSearchIcon_mc.x + this.TaggedForSearchIcon_mc.width / 2 + 10) : Number(this.TaggedForSearchIcon_mc.x);
            this.FavoriteIcon_mc.x = !!this.LegendaryIcon_mc.visible ? Number(this.LegendaryIcon_mc.x + this.LegendaryIcon_mc.width / 2 + 10) : !!this.TaggedForSearchIcon_mc.visible ? Number(this.TaggedForSearchIcon_mc.x + this.TaggedForSearchIcon_mc.width / 2 + 10) : Number(this.TaggedForSearchIcon_mc.x);
        }
    }
}
