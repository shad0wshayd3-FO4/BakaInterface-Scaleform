package Menu.ContainerMenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;

    public dynamic class PlayerInventory extends MovieClip
    {
        public var PlayerCaps_tf:TextField;
        public var PlayerWeight_tf:TextField;
        public var PlayerListHeader:ListHeader;
        public var PlayerList_mc:PlayerList;
        public var PlayerBracketBackground_mc:MovieClip;
        public var PlayerSwitchButton_tf:TextField;

        public function PlayerInventory()
        {
            super();
            this.__setProp_PlayerList_mc_PlayerInventory_Layer1_0();
        }

        function __setProp_PlayerList_mc_PlayerInventory_Layer1_0():*
        {
            this.PlayerList_mc.listEntryClass = "Menu.ContainerMenu.PlayerListEntry";
            this.PlayerList_mc.numListItems = 16;
            this.PlayerList_mc.restoreListIndex = true;
            this.PlayerList_mc.textOption = "Shrink To Fit";
            this.PlayerList_mc.verticalSpacing = -2;
        }
    }
}
