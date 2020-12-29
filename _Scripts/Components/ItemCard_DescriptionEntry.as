package Components
{
    import flash.display.MovieClip;
    import flash.text.TextFieldAutoSize;
    import scaleform.gfx.TextFieldEx;

    public class ItemCard_DescriptionEntry extends ItemCard_Entry
    {
        public var Background_mc:MovieClip;

        public function ItemCard_DescriptionEntry()
        {
            super();
            TextFieldEx.setTextAutoSize(Label_tf, TextFieldEx.TEXTAUTOSZ_NONE);
            Label_tf.autoSize = TextFieldAutoSize.LEFT;
            Label_tf.multiline = true;
            Label_tf.wordWrap = true;
        }

        override public function PopulateEntry(param1:Object):*
        {
            super.PopulateEntry(param1);
            this.Background_mc.height = Label_tf.textHeight + 5;
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
                    _loc2_ = _loc2_ + ("$$ItemCard_DescriptionEntryConcatenator " + _loc3_.text);
                }
            }
            PopulateText(_loc2_);
            this.Background_mc.height = Label_tf.textHeight + 5;
        }
    }
}
