package Menu.BarterMenu
{
    import flash.display.MovieClip;

    public dynamic class FilterHolder extends MovieClip
    {
        public var Menu_mc: BarterMenu;

        public function FilterHolder()
        {
            super();
            addFrameScript(this.totalFrames - 1, this.onEndFrame);
        }

        function onEndFrame():*
        {
            this.Menu_mc.onIntroAnimComplete();
            stop();
        }
    }
}
