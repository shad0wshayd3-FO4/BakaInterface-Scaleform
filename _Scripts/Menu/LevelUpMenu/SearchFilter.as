package Menu.LevelUpMenu
{
    import Shared.AS3.ListFilterer;
    import flash.events.Event;

    public class SearchFilter extends ListFilterer
    {

        private var _FilterString:String;

        public function SearchFilter()
        {
            super();
            this._FilterString = "";
        }

        public function get filterString():String
        {
            return this._FilterString;
        }

        public function set filterString(a_newFilter:String):*
        {
            var Filter:String = a_newFilter.toLowerCase();
            if (this._FilterString != Filter)
            {
                this._FilterString = Filter;
                this._countUpdated = false;
                dispatchEvent(new Event(ListFilterer.FILTER_CHANGE, true, true));
            }
        }

        override public function EntryMatchesFilter(entry:Object):Boolean
        {
            if (entry != null)
            {
                if (this._FilterString.length == 0)
                {
                    return true;
                }

                if (entry.hasOwnProperty("text"))
                {
                    var Text:String = entry.text.toLowerCase();
                    if (Text.indexOf(this._FilterString) >= 0)
                    {
                        return true;
                    }
                }

                if (entry.hasOwnProperty("RankDescs"))
                {
                    var RankDescs:Array = entry.RankDescs;
                    for (var i:uint = 0; i < RankDescs.length; i++)
                    {
                        var Text:String = RankDescs[i].toLowerCase();
                        if (Text.indexOf(this._FilterString) >= 0)
                        {
                            return true;
                        }
                    }
                }
            }

            return false;
        }
    }
}
