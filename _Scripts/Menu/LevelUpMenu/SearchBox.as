package Menu.LevelUpMenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;

    public class SearchBox extends MovieClip
    {
        public var SearchText_tf:TextField;

        public function SearchBox()
        {
            super();
			
			this.SearchText_tf.restrict = "A-z0-9\\-_=<> ";
        }
    }
}
