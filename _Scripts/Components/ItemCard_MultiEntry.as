package Components
{
    import Shared.GlobalFunc;
    import flash.display.MovieClip;

    public class ItemCard_MultiEntry extends ItemCard_Entry
    {
        public static const DMG_WEAP_ID:String = "$dmg";
        public static const DMG_ARMO_ID:String = "$dr";

        public var EntryHolder_mc:MovieClip;
        public var Background_mc:MovieClip;
        private var m_EntrySpacing:Number = 3.5;
        private var m_EntryCount:int = 0;

        public function ItemCard_MultiEntry()
        {
            super();
        }

        public static function IsEntryValid(param1:Object):Boolean
        {
            return param1.value > 0 || ShouldShowDifference(param1) && param1.text == DMG_ARMO_ID;
        }

        public function set entrySpacing(param1:Number):*
        {
            this.m_EntrySpacing = param1;
        }

        public function get entryCount():int
        {
            return this.m_EntryCount;
        }

        public function PopulateMultiEntry(param1:Array, param2:String):*
        {
            var _loc5_:ItemCard_MultiEntry_Value = null;
            if (Label_tf != null)
            {
                GlobalFunc.SetText(Label_tf, param2, false);
            }
            while (this.EntryHolder_mc.numChildren > 0)
            {
                this.EntryHolder_mc.removeChildAt(0);
            }
            var _loc3_:Number = 0;
            this.m_EntryCount = 0;
            var _loc4_:uint = 0;
            while (_loc4_ < param1.length)
            {
                if (param1[_loc4_].text == param2 && IsEntryValid(param1[_loc4_]))
                {
                    _loc5_ = new ItemCard_MultiEntry_Value();
                    _loc5_.Icon_mc.gotoAndStop(param2 == DMG_WEAP_ID ? param1[_loc4_].damageType + GlobalFunc.NUM_DAMAGE_TYPES : param1[_loc4_].damageType);
                    _loc5_.PopulateEntry(param1[_loc4_]);
                    this.EntryHolder_mc.addChild(_loc5_);
                    this.m_EntryCount++;
                    if (_loc3_ > 0)
                    {
                        _loc3_ = _loc3_ + this.m_EntrySpacing;
                    }
                    _loc5_.y = _loc3_;
                    if (_loc5_.Sizer_mc != null)
                    {
                        _loc3_ = _loc3_ + _loc5_.Sizer_mc.height;
                    }
                    else
                    {
                        _loc3_ = _loc3_ + _loc5_.height;
                    }
                }
                _loc4_++;
            }
            if (this.Background_mc != null)
            {
                this.Background_mc.height = _loc3_;
            }
        }
    }
}
