package Components
{
    import Shared.AS3.BSUIComponent;

    public class ItemCard extends BSUIComponent
    {
        private var _InfoObj:Array;
        private var _showItemDesc:Boolean;
        private var _showValueEntry:Boolean;
        private var bItemHealthEnabled:Boolean;

        private const ET_STANDARD:uint = 0;
        private const ET_AMMO:uint = 1;
        private const ET_DMG_WEAP:uint = 2;
        private const ET_DMG_ARMO:uint = 3;
        private const ET_TIMED_EFFECT:uint = 4;
        private const ET_COMPONENTS_LIST:uint = 5;
        private const ET_ITEM_DESCRIPTION:uint = 6;
        private const ET_LEGENDARY_AND_LEVEL:uint = 7;
        private const ET_ITEM_HEALTH:uint = 7;

        private var m_BlankEntryFillTarget:uint = 0;
        private var m_EntrySpacing:Number = -3.5;
        private var m_EntrySpacingChanged:Boolean = false;
        private var m_EntryCount:int = 0;
        private var m_BottomUp:Boolean = true;

        public function ItemCard()
        {
            super();
            this._InfoObj = new Array();
            this._showItemDesc = true;
            this._showValueEntry = true;
            this.bItemHealthEnabled = true;
        }

        public function set blankEntryFillTarget(param1:uint):void
        {
            this.m_BlankEntryFillTarget = param1;
        }

        public function get blankEntryFillTarget():uint
        {
            return this.m_BlankEntryFillTarget;
        }

        public function set entrySpacing(param1:Number):*
        {
            this.m_EntrySpacing = param1;
            this.m_EntrySpacingChanged = true;
        }

        public function get entryCount():int
        {
            return this.m_EntryCount;
        }

        public function get entrySpacing():Number
        {
            return this.m_EntrySpacing;
        }

        public function set bottomUp(param1:Boolean):*
        {
            this.m_BottomUp = param1;
        }

        public function get bottomUp():Boolean
        {
            return this.m_BottomUp;
        }

        public function get InfoObj():Array
        {
            return this._InfoObj;
        }

        public function set InfoObj(param1:Array):*
        {
            this._InfoObj = param1;
        }

        public function set showItemDesc(param1:Boolean):*
        {
            this._showItemDesc = param1;
        }

        public function get showItemDesc():Boolean
        {
            return this._showItemDesc;
        }

        public function set showValueEntry(param1:Boolean):*
        {
            this._showValueEntry = param1;
        }

        public function get showValueEntry():Boolean
        {
            return this._showValueEntry;
        }

        public function onDataChange():*
        {
            SetIsDirty();
        }

        override public function redrawUIComponent():void
        {
            var _loc2_:ItemCard_Entry = null;
            var _loc15_:uint = 0;
            var _loc16_:Object = null;
            var _loc17_:ItemCard_DescriptionEntry = null;
            super.redrawUIComponent();
            while (this.numChildren > 0)
            {
                this.removeChildAt(0);
            }
            var _loc1_:Number = 0;
            var _loc3_:Vector.<ItemCard_Entry> = new Vector.<ItemCard_Entry>();
            var _loc4_:Boolean = false;
            var _loc5_:Boolean = false;
            var _loc6_:Array = new Array();
            var _loc8_:Object = new Object();
            var _loc12_:int = this._InfoObj.length - 1;
            while (_loc12_ >= 0)
            {
                switch (this._InfoObj[_loc12_].text)
                {
                    case ItemCard_MultiEntry.DMG_WEAP_ID:
                        _loc4_ = _loc4_ || ItemCard_MultiEntry.IsEntryValid(this._InfoObj[_loc12_]);
                        break;
                    case ItemCard_MultiEntry.DMG_ARMO_ID:
                        _loc5_ = _loc5_ || ItemCard_MultiEntry.IsEntryValid(this._InfoObj[_loc12_]);
                        break;
                    case "$health":
                        _loc8_.currentHealth = this._InfoObj[_loc12_].currentHealth;
                        _loc8_.maxMeterHealth = this._InfoObj[_loc12_].maximumHealth;
                        _loc8_.maximumHealth = this._InfoObj[_loc12_].maximumHealth;
                        break;
                    case "currentHealth":
                        _loc8_.currentHealth = this._InfoObj[_loc12_].value;
                        break;
                    case "maxMeterHealth":
                        _loc8_.maxMeterHealth = this._InfoObj[_loc12_].value;
                        break;
                    case "minMeterHealth":
                        _loc8_.minMeterHealth = this._InfoObj[_loc12_].value;
                        break;
                    case "healthPercent":
                        break;
                    case "maximumHealth":
                        _loc8_.maxMeterHealth = this._InfoObj[_loc12_].value;
                        _loc8_.maximumHealth = this._InfoObj[_loc12_].value;
                        break;
                    default:
                        if (this._InfoObj[_loc12_].showAsDescription != true)
                        {
                            _loc15_ = this.GetEntryType(this._InfoObj[_loc12_]);
                            _loc2_ = this.CreateEntry(_loc15_);
                            if (_loc2_ != null)
                            {
                                _loc2_.PopulateEntry(this._InfoObj[_loc12_]);
                                _loc3_.push(_loc2_);
                            }
                        }
                }
                _loc12_--;
            }
            if (this._showItemDesc)
            {
                for each (_loc16_ in this._InfoObj)
                {
                    if (_loc16_.showAsDescription == true)
                    {
                        _loc6_.push(_loc16_);
                    }
                }
            }
            if (_loc4_)
            {
                _loc2_ = this.CreateEntry(this.ET_DMG_WEAP);
                if (_loc2_ != null)
                {
                    (_loc2_ as ItemCard_MultiEntry).PopulateMultiEntry(this._InfoObj, ItemCard_MultiEntry.DMG_WEAP_ID);
                    _loc3_.push(_loc2_);
                }
            }
            if (_loc5_)
            {
                _loc2_ = this.CreateEntry(this.ET_DMG_ARMO);
                if (_loc2_ != null)
                {
                    (_loc2_ as ItemCard_MultiEntry).PopulateMultiEntry(this._InfoObj, ItemCard_MultiEntry.DMG_ARMO_ID);
                    _loc3_.push(_loc2_);
                }
            }
            if (_loc8_.maxMeterHealth > 0 && _loc8_.currentHealth != -1 && this.bItemHealthEnabled)
            {
                _loc2_ = this.CreateEntry(this.ET_ITEM_HEALTH);
                if (_loc2_ != null)
                {
                    (_loc2_ as ItemCard_ItemHealthEntry).PopulateEntry(_loc8_);
                    _loc3_.push(_loc2_);
                }
            }
            if (_loc6_.length > 0)
            {
                _loc2_ = this.CreateEntry(this.ET_ITEM_DESCRIPTION);
                _loc17_ = _loc2_ as ItemCard_DescriptionEntry;
                if (_loc17_ != null)
                {
                    _loc17_.PopulateEntries(_loc6_);
                    _loc3_.push(_loc2_);
                }
            }
            this.FillBlankEntries(_loc3_);
            var _loc13_:int = _loc3_.length;
            if (!this.m_BottomUp)
            {
                _loc3_.reverse();
            }
            this.m_EntryCount = 0;
            var _loc14_:int = 0;
            while (_loc14_ < _loc13_)
            {
                addChild(_loc3_[_loc14_]);
                if (_loc3_[_loc14_] is ItemCard_MultiEntry)
                {
                    this.m_EntryCount = this.m_EntryCount + (_loc3_[_loc14_] as ItemCard_MultiEntry).entryCount;
                }
                else if (_loc3_[_loc14_] is ItemCard_ComponentsEntry)
                {
                    this.m_EntryCount = this.m_EntryCount + (_loc3_[_loc14_] as ItemCard_ComponentsEntry).entryCount;
                }
                else
                {
                    this.m_EntryCount++;
                }
                if (this.m_BottomUp)
                {
                    if (_loc1_ < 0)
                    {
                        _loc1_ = _loc1_ - this.m_EntrySpacing;
                    }
                    _loc1_ = _loc1_ - _loc3_[_loc14_].height;
                    _loc3_[_loc14_].y = _loc1_;
                }
                else
                {
                    _loc3_[_loc14_].y = _loc1_;
                    _loc1_ = _loc1_ + (_loc3_[_loc14_].height + this.m_EntrySpacing);
                }
                _loc14_++;
            }
        }

        private function FillBlankEntries(param1:Vector.<ItemCard_Entry>):void
        {
            var _loc5_:ItemCard_Entry = null;
            var _loc6_:uint = 0;
            var _loc2_:int = 0;
            var _loc3_:int = param1.length;
            var _loc4_:int = 0;
            while (_loc4_ < _loc3_)
            {
                if (param1[_loc4_] is ItemCard_MultiEntry)
                {
                    _loc2_ = _loc2_ + (param1[_loc4_] as ItemCard_MultiEntry).entryCount;
                }
                else if (param1[_loc4_] is ItemCard_ComponentsEntry)
                {
                    _loc2_ = _loc2_ + (param1[_loc4_] as ItemCard_ComponentsEntry).entryCount;
                }
                else
                {
                    _loc2_++;
                }
                _loc4_++;
            }
            if (_loc2_ < this.m_BlankEntryFillTarget)
            {
                _loc6_ = _loc2_;
                while (_loc6_ < this.m_BlankEntryFillTarget)
                {
                    _loc5_ = new ItemCard_StandardEntry();
                    _loc5_.PopulateEntry({"text": "", "value": ""});
                    param1.unshift(_loc5_);
                    _loc6_++;
                }
            }
        }

        private function GetEntryType(param1:Object):uint
        {
            var _loc2_:uint = this.ET_STANDARD;
            if (param1.damageType == 10)
            {
                _loc2_ = this.ET_AMMO;
            }
            else if (param1.duration != null && param1.duration > 0)
            {
                _loc2_ = this.ET_TIMED_EFFECT;
            }
            else if (param1.components is Array && param1.components.length > 0)
            {
                _loc2_ = this.ET_COMPONENTS_LIST;
            }
            return _loc2_;
        }

        private function CreateEntry(param1:uint):ItemCard_Entry
        {
            var _loc2_:ItemCard_Entry = null;
            switch (param1)
            {
                case this.ET_STANDARD:
                    _loc2_ = new ItemCard_StandardEntry();
                    break;
                case this.ET_AMMO:
                    _loc2_ = new ItemCard_AmmoEntry();
                    break;
                case this.ET_DMG_WEAP:
                case this.ET_DMG_ARMO:
                    _loc2_ = new ItemCard_MultiEntry();
                    if (this.m_EntrySpacingChanged)
                    {
                        (_loc2_ as ItemCard_MultiEntry).entrySpacing = this.m_EntrySpacing;
                    }
                    break;
                case this.ET_TIMED_EFFECT:
                    _loc2_ = new ItemCard_TimedEntry();
                    break;
                case this.ET_COMPONENTS_LIST:
                    _loc2_ = new ItemCard_ComponentsEntry();
                    break;
                case this.ET_ITEM_DESCRIPTION:
                    _loc2_ = new ItemCard_DescriptionEntry();
                    break;
                case this.ET_ITEM_HEALTH:
                    _loc2_ = new ItemCard_ItemHealthEntry();
                    break;
            }
            return _loc2_;
        }

        public function HideItemHealth():*
        {
            this.bItemHealthEnabled = false;
        }
    }
}
