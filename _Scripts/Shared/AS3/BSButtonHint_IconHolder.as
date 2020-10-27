package Shared.AS3
{
    import flash.display.MovieClip;

    public dynamic class BSButtonHint_IconHolder extends MovieClip
    {
        public var IconAnimInstance:MovieClip;

        public function BSButtonHint_IconHolder()
        {
            super();
            addFrameScript(0, this.frame1, 59, this.frame60);
        }

        function frame1():*
        {
            stop();
        }

        function frame60():*
        {
            gotoAndPlay("Flashing");
        }
    }
}
