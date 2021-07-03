package Menu.ContainerMenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	public dynamic class ContainerInventory extends MovieClip
	{
		public var CapsText_tf: TextField;
		public var CapsIcon_mc: MovieClip;
		public var WeightText_tf: TextField;
		public var WeightIcon_mc: MovieClip;
		public var ContainerListHeader: ListHeader;
		public var ContainerBracketBackground_mc: MovieClip;
		public var ContainerSwitchButton_tf: TextField;

		public function ContainerInventory()
		{
			super();
		}
	}
}