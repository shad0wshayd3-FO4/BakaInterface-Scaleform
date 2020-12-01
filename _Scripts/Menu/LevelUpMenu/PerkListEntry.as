package Menu.LevelUpMenu
{
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;
    import Shared.AS3.BSScrollingListEntry;

    public class PerkListEntry extends BSScrollingListEntry
    {
        public var SelectionRect_mc:MovieClip;

        public function PerkListEntry()
        {
            super();
        }

        override public function SetEntryText(param1:Object, param2:String):*
        {
            super.SetEntryText(param1, param2);

            var color:Number = (this.selected) ? 0.0 : 1.0;
            this.SelectionRect_mc.transform.colorTransform = new ColorTransform(color, color, color);
            this.SelectionRect_mc.visible = param1.IsSelected;

            if (!param1.IsAvailable)
            {
                this.textField.textColor = 0x888888;
            }
        }
    }
}
