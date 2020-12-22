package Shared.AS3.Events
{
    import flash.events.Event;

    public class MenuActionEvent extends Event
    {
        public static const MENU_HOVER:String = "MenuHover";
        public static const MENU_ACCEPT:String = "MenuAccept";
        public static const MENU_CANCEL:String = "MenuCancel";

        public static const ACTION_MULTIACTION:String = "MultiAction";
        public static const ACTION_OPENSUBMENU:String = "OpenSubMenu";
        public static const ACTION_OPENSECONDARYSUBMENU:String = "OpenSecondarySubMenu";
        public static const ACTION_SENDEVENT:String = "Event";

        public static const SHOW_SETTINGS:String = "ShowSettings";


        private var _action:String = "";
        private var _data:String = "";
        private var _index:Number = 0;
        private var _tooltip:String = "";
        private var _entryObject:Object = "";

        public function MenuActionEvent(param1:String, param2:String, param3:String, param4:Number = 0, param5:String = "", param6:Object = null, param7:Boolean = false, param8:Boolean = false)
        {
            this._action = param2;
            this._data = param3;
            this._index = param4;
            this._tooltip = param5;
            this._entryObject = param6;
            super(param1, param7, param8);
        }

        public function get Action():*
        {
            return this._action;
        }

        public function set Action(param1:String):*
        {
            this._action = param1;
        }

        public function get Data():*
        {
            return this._data;
        }

        public function set Data(param1:String):*
        {
            this._data = param1;
        }

        public function get Index():*
        {
            return this._index;
        }

        public function set Index(param1:Number):*
        {
            this._index = param1;
        }

        public function get Tooltip():*
        {
            return this._tooltip;
        }

        public function set Tooltip(param1:String):*
        {
            this._tooltip = param1;
        }

        public function get EntryObject():*
        {
            return this._entryObject;
        }

        public function set EntryObject(param1:Object):*
        {
            this._entryObject = param1;
        }

        override public function clone():Event
        {
            return new MenuActionEvent(type, this._action, this._data, this._index, this._tooltip, this._entryObject, bubbles, cancelable);
        }
    }
}
