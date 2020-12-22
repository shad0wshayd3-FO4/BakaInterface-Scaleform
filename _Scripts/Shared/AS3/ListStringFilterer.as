package Shared.AS3
{
    import flash.events.Event;
    import flash.events.EventDispatcher;

    public class ListStringFilterer extends ListFilterer
    {
        private var _filterString:String = "";

        public function ListStringFilterer()
        {
            super();
        }

        public function get filterString():String
        {
            return this._filterString;
        }

        public function set filterString(param1:String):*
        {
            var filterStr:String = param1.toLowerCase();
            if (this._filterString != filterStr)
            {
                this._filterString = filterStr;
                dispatchEvent(new Event(ListFilterer.FILTER_CHANGE, true, true));
            }
        }

        override public function EntryMatchesFilter(param1:Object):Boolean
        {
            if (this.filterString.length == 0)
            {
                return true;
            }

            if (param1 != null && param1.hasOwnProperty("text"))
            {
                var checkStr:String = param1.text.toLowerCase();
                if (checkStr.indexOf(this.filterString) >= 0)
                {
                    return true;
                }
            }

            return false;
        }
    }
}
