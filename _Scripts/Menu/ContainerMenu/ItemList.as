package Menu.ContainerMenu
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import Shared.AS3.BSScrollingScrollList;

    public class ItemList extends BSScrollingScrollList
    {
        public static const MOUSE_OVER:String = "ItemList::mouse_over";

        public function ItemList()
        {
            super();
            addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        }

        private function onMouseOver(event:MouseEvent):*
        {
            dispatchEvent(new Event(MOUSE_OVER, true, true));
        }
    }
}
