package Menu.SleepWaitMenu
{
    import flash.display.MovieClip;

    public dynamic class FadeInBGRect extends MovieClip
    {
        public function FadeInBGRect()
        {
            super();
            addFrameScript(0, this.frame1, 119, this.frame120);
        }

        function frame1():*
        {
            stop();
        }

        function frame120():*
        {
            stop();
        }
    }
}
