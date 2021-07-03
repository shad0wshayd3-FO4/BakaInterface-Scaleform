package Menu.ContainerMenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	public dynamic class PlayerInventory extends MovieClip
	{
		public var CapsText_tf: TextField;
		public var CapsIcon_mc: MovieClip;
		public var WeightText_tf: TextField;
		public var WeightIcon_mc: MovieClip;
		public var PlayerListHeader: ListHeader;
		public var PlayerList_mc: PlayerList;
		public var PlayerBracketBackground_mc: MovieClip;
		public var PlayerSwitchButton_tf: TextField;

		public function PlayerInventory()
		{
			super();
		}
	}
}