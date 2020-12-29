package Components
{
    import Shared.GlobalFunc;
    import flash.display.MovieClip;

    public class ItemCard_ItemHealthEntry extends ItemCard_Entry
    {
        public var ConditionMeter_mc:MovieClip;

        private var m_ConditionLengthFrames:int = 100;
        private var m_ConditionFrames:int = 110;

        public function ItemCard_ItemHealthEntry()
        {
            super();
        }

        public static function IsEntryValid(param1:Object):Boolean
        {
            return param1.currentHealth != -1;
        }

        override public function PopulateEntry(param1:Object):*
        {
            GlobalFunc.updateConditionMeter(this.ConditionMeter_mc, param1.currentHealth, param1.maximumHealth, param1.durability);
        }
    }
}
