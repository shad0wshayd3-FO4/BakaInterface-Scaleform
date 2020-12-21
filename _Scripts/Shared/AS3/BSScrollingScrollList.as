package Shared.AS3
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import Shared.AS3.BSScrollingList;

    public class BSScrollingScrollList extends BSScrollingList
    {
        public static const MOUSE_OVER:String = "BSScrollingScrollList::mouse_over";

        public var ScrollBar_mc:Option_Scrollbar;

        public function BSScrollingScrollList()
        {
            super();

            if (this.ScrollBar_mc != null)
            {
                this.ScrollBar_mc.StepSize = 1.0;
                addEventListener(Option_Scrollbar.VALUE_CHANGE, this.updateValueFromScrollBar);
            }

            addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
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
                // if (this.iMaxScrollPosition == 0)
                // {
                //     this.SetVisibility(false);
                // }
                // else
                // {
                    this.SetVisibility(true);
                    this.ScrollBar_mc.value = this.scrollPosition;
                    this.ScrollBar_mc.MinValue = 0;
                    this.ScrollBar_mc.MaxValue = this.iMaxScrollPosition;

                    var mod:Number = Math.min((this.uiNumListItems / this._filterer.GetFilterCount()), 1.0);
                    this.ScrollBar_mc.Thumb_mc.width = this.ScrollBar_mc.Track_mc.width * mod;
                    this.ScrollBar_mc.UpdateThumbX();
                // }
            }
        }

        private function SetVisibility(a_visible:Boolean):*
        {
            this.ScrollBar_mc.visible = a_visible;
        }

        private function onMouseOver(event:MouseEvent):*
        {
            dispatchEvent(new Event(MOUSE_OVER, true, true));
        }
    }
}
