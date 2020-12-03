package Menu.ContainerMenu
{
    import flash.display.MovieClip;

    public dynamic class FilterHolder extends MovieClip
    {
        public var Menu_mc:ContainerMenu;

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
