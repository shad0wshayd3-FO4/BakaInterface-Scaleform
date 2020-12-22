package Menu.LevelUpMenu
{
    import Shared.AS3.ListStringFilterer;

    public class PerkListFilter extends ListStringFilterer
    {
        public function PerkListFilter()
        {
            super();
        }

        override public function EntryMatchesFilter(param1:Object):Boolean
        {
            if (super.EntryMatchesFilter(param1))
            {
                return true;
            }

            if (param1 != null && param1.hasOwnProperty("RankDescs"))
            {
                for (var i:uint = 0; i < param1.RankDescs.length; i++)
                {
                    var checkStr:String = param1.RankDescs[i].toLowerCase();
                    if (checkStr.indexOf(this.filterString) >= 0)
                    {
                        return true;
                    }
                }
            }

            return false;
        }
    }
}
