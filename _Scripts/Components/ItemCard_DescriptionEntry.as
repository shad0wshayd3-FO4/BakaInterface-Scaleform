package Components
{
    import flash.display.MovieClip;
    import flash.text.TextFieldAutoSize;
    import scaleform.gfx.TextFieldEx;

    public class ItemCard_DescriptionEntry extends ItemCard_Entry
    {
        public var Background_mc:MovieClip;
		
		private var _BackgroundHeight:Number;
		private var _SizerHeight:Number;

        public function ItemCard_DescriptionEntry()
        {
            super();
			
			this._BackgroundHeight = this.Background_mc.height;
			this._SizerHeight = this.Sizer_mc.height;
			
            TextFieldEx.setTextAutoSize(Label_tf, TextFieldEx.TEXTAUTOSZ_NONE);
            this.Label_tf.autoSize = TextFieldAutoSize.LEFT;
            this.Label_tf.multiline = true;
            this.Label_tf.wordWrap = true;
        }

        override public function PopulateEntry(param1:Object):*
        {
            super.PopulateEntry(param1);
        }

        public function PopulateEntries(param1:Array):*
        {
            var _loc3_:Object = null;
            super.PopulateEntry(param1[0]);
            var _loc2_:String = "";
            for each (_loc3_ in param1)
            {
                if (_loc2_ == "")
                {
                    _loc2_ = _loc3_.text;
                }
                else
                {
                    _loc2_ = _loc2_ + (", " + _loc3_.text);
                }
            }
            this.PopulateText(_loc2_);
			
            this.Background_mc.height = Math.max(this.Label_tf.textHeight + 5, this._BackgroundHeight);
			this.Sizer_mc.height = this._SizerHeight + (this.Background_mc.height - this._BackgroundHeight);
        }
    }
}
