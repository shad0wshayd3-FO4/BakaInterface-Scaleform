package Menu.ContainerMenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextLineMetrics;
    import scaleform.gfx.Extensions;
    import scaleform.gfx.TextFieldEx;
	import Shared.GlobalFunc;

    public class ListHeader extends MovieClip
    {
        public var textField:TextField;

        public function ListHeader()
        {
            super();
            Extensions.enabled = true;
            TextFieldEx.setTextAutoSize(this.textField, "shrink");
        }

        public function get headerText():String
        {
            return this.textField.text;
        }

        public function get headerWidth():*
        {
			metrics = this.textField.getLineMetrics(0);
            return this.textField.x + metrics.width + 10;
        }

        public function set headerText(strText:String):void
        {
            var metrics:TextLineMetrics = null;
            if (this.textField && strText)
            {
                GlobalFunc.SetText(this.textField, strText, false);
            }
        }
    }
}
