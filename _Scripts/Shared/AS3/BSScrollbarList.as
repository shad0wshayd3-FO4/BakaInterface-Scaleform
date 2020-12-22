package Shared.AS3
{
    import flash.events.Event;

    public class BSScrollbarList extends BSScrollingList
    {
        public var Scrollbar:BSSlider;

        public function BSScrollbarList()
        {
            super();

            if (this.Scrollbar != null)
            {
                this.Scrollbar.bVertical = true;
                this.Scrollbar.handleSizeViaContents = true;
                addEventListener(BSSlider.VALUE_CHANGED, this.updateValueFromScrollbar);
            }
        }

        private function updateValueFromScrollbar(param1:Event):void
        {
            if (this.Scrollbar != null)
            {
                this.scrollPosition = this.Scrollbar.value;
            }
        }

        override protected function updateScrollPosition(param1:uint):*
        {
            super.updateScrollPosition(param1);

            if (this.Scrollbar != null)
            {
                this.Scrollbar.value = this.scrollPosition;
            }
        }

        override protected function CalculateMaxScrollPosition():*
        {
            super.CalculateMaxScrollPosition();

            if (this.Scrollbar != null)
            {
                this.Scrollbar.value = this.scrollPosition;
                this.Scrollbar.minValue = 0;
                this.Scrollbar.maxValue = this.iMaxScrollPosition;
            }
        }
    }
}
