package Shared.AS3
{
	import flash.events.Event;
    import flash.display.MovieClip;
    import Shared.AS3.BSScrollingList;

    public class BSScrollingListSB extends BSScrollingList
    {
		public var ScrollBar_mc:Option_Scrollbar;
		
        public function BSScrollingListSB()
        {
            super();

			if (this.ScrollBar_mc != null)
			{
				this.ScrollBar_mc.StepSize = 1.0;
				addEventListener(Option_Scrollbar.VALUE_CHANGE, this.updateValueFromScrollBar);
			}
		}
		
		private function updateValueFromScrollBar(param1:Event):void
		{
			if (this.ScrollBar_mc != null)
			{
				this.scrollPosition = this.ScrollBar_mc.value;
			}
		}
		
		override public function set filterer(param1:ListFilterer):*
        {
            this._filterer = param1;
			this._filterer.addEventListener(ListFilterer.FILTER_CHANGE, this.onFilterChangeImpl);
        }
		
		public function onFilterChangeImpl():*
		{
			this.selectedIndex = this._filterer.ClampIndex(this.selectedIndex);
			this.CalculateMaxScrollPosition();
			this.UpdateList();
			
			if (this.shownItemsHeight < this.border.height)
			{
				this.scrollPosition = 0;
			}
		}
		
		override protected function updateScrollPosition(param1:uint):*
		{
			super.updateScrollPosition(param1);
			
			if (this.ScrollBar_mc != null)
			{
				this.ScrollBar_mc.value = this.scrollPosition;
			}
		}
		
		override protected function CalculateMaxScrollPosition():*
		{
			super.CalculateMaxScrollPosition();

			if (this.ScrollBar_mc != null)
			{
				if (this.iMaxScrollPosition == 0)
				{
					this.ScrollBar_mc.visible = false;
				}
				else
				{
					this.ScrollBar_mc.visible = true;
					this.ScrollBar_mc.value = this.scrollPosition;
					this.ScrollBar_mc.MinValue = 0;
					this.ScrollBar_mc.MaxValue = this.iMaxScrollPosition;
					
					var mod:Number = Math.min((this.uiNumListItems / this._filterer.GetFilterCount()), 1.0);
					this.ScrollBar_mc.Thumb_mc.width = this.ScrollBar_mc.Track_mc.width * mod;
					this.ScrollBar_mc.UpdateThumbX();
				}
			}
		}
    }
}
