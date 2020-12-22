package Menu.LevelUpMenu
{
    import flash.display.MovieClip;
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

            this.SetColorTransform(this.SelectionRect_mc, param1.IsSelected);
            this.SelectionRect_mc.visible = param1.IsSelected;

            if (!param1.IsAvailable)
            {
                this.textField.textColor = 0x888888;
            }
        }
    }
}
