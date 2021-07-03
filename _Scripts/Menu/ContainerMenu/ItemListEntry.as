package Menu.ContainerMenu
{
    import Shared.AS3.BSScrollingListEntry;
    import Shared.GlobalFunc;
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;

    public class ItemListEntry extends BSScrollingListEntry
    {
        public var BarterIcon_mc:MovieClip;
		public var EquipIcon_mc:MovieClip;
		public var LegendaryIcon_mc:MovieClip;
        public var FavoriteIcon_mc:MovieClip;
        public var TaggedForSearchIcon_mc:MovieClip;

        private var BaseTextFieldWidth;

        public function ItemListEntry()
        {
            super();
            this.BaseTextFieldWidth = textField.width;
        }

        override public function SetEntryText(aEntryObject:Object, astrTextOption:String):*
        {
            this.LegendaryIcon_mc.visible = aEntryObject.isLegendary == true;
			this.FavoriteIcon_mc.visible = aEntryObject.favorite > 0;
			this.TaggedForSearchIcon_mc.visible = aEntryObject.taggedForSearch == true;
			
            var textFieldWidthDelta:Number = 0;
			if (this.LegendaryIcon_mc.visible && this.FavoriteIcon_mc.visible)
            {
                textFieldWidthDelta = textFieldWidthDelta + (this.LegendaryIcon_mc.width / 2.0) + 10;
            }
            if (this.FavoriteIcon_mc.visible && this.TaggedForSearchIcon_mc.visible)
            {
                textFieldWidthDelta = textFieldWidthDelta + (this.FavoriteIcon_mc.width / 2.0) + 10;
            }
			
            textField.width = this.BaseTextFieldWidth - textFieldWidthDelta;
            super.SetEntryText(aEntryObject, astrTextOption);

            var barterCount:int = 0;
            if (aEntryObject.hasOwnProperty("barterCount"))
            {
                barterCount = aEntryObject.barterCount;
            }

            var displayCount:int = aEntryObject.count - barterCount;
            GlobalFunc.SetText(textField, textField.text, false, false, true);
            if (displayCount != 1)
            {
                textField.appendText(" (" + displayCount + ")");
            }
			
            GlobalFunc.SetText(textField, textField.text);
            this.SetColorTransform(this.BarterIcon_mc, this.selected);
			this.SetColorTransform(this.EquipIcon_mc, this.selected);
			this.SetColorTransform(this.LegendaryIcon_mc, this.selected);
            this.SetColorTransform(this.FavoriteIcon_mc, this.selected);
            this.SetColorTransform(this.TaggedForSearchIcon_mc, this.selected);

            this.EquipIcon_mc.visible = aEntryObject.equipState != 0;
            if (this.BarterIcon_mc != null)
            {
                this.BarterIcon_mc.visible = barterCount < 0;
				this.EquipIcon_mc.visible = this.BarterIcon_mc.visible ? false : this.EquipIcon_mc.visible;
            }

            this.TaggedForSearchIcon_mc.x = this.textField.getLineMetrics(0).width + this.textField.x + 10;
            this.LegendaryIcon_mc.x = !!this.TaggedForSearchIcon_mc.visible ? Number(this.TaggedForSearchIcon_mc.x + this.TaggedForSearchIcon_mc.width / 2 + 10) : Number(this.TaggedForSearchIcon_mc.x);
            this.FavoriteIcon_mc.x = !!this.LegendaryIcon_mc.visible ? Number(this.LegendaryIcon_mc.x + this.LegendaryIcon_mc.width / 2 + 10) : !!this.TaggedForSearchIcon_mc.visible ? Number(this.TaggedForSearchIcon_mc.x + this.TaggedForSearchIcon_mc.width / 2 + 10) : Number(this.TaggedForSearchIcon_mc.x);
        }
    }
}
