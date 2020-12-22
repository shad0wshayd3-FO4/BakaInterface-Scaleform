package Menu.PluginExplorerMenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;

    public class ItemListSearch extends MovieClip
    {
        public var SearchText_tf:TextField;

        public function ItemListSearch()
        {
            super();

            this.SearchText_tf.restrict = "A-z0-9\\-_=<> ";
        }
    }
}
