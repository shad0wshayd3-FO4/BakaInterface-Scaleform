package Menu.PluginExplorerMenu
{
    import Shared.AS3.ListStringFilterer;

    public class FormFilter extends ListStringFilterer
    {
        public function FormFilter()
        {
            super();
        }

        override public function EntryMatchesFilter(param1:Object):Boolean
        {
            if (super.EntryMatchesFilter(param1))
            {
                return true;
            }

            if (param1 != null && param1.hasOwnProperty("textFormID"))
            {
                var checkStr:String = param1.textFormID.toLowerCase();
                if (checkStr.indexOf(this.filterString) >= 0)
                {
                    return true;
                }
            }

            return false;
        }
    }
}
