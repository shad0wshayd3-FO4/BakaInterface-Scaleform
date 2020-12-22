package Menu.PluginExplorerMenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;

    public class PluginListSearch extends MovieClip
    {
        public var SearchText_tf:TextField;

        public function PluginListSearch()
        {
            super();

            this.SearchText_tf.restrict = "A-z0-9\\-_=<> ";
        }
    }
}
