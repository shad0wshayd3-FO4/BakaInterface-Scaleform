package Components
{
	import Shared.AS3.BSUIComponent;

	public class ItemCard extends BSUIComponent
	{
		private var _InfoObj: Array;
		private var _showItemDesc: Boolean;
		private var _showValueEntry: Boolean;
		private var bItemHealthEnabled: Boolean;

		private const ET_STANDARD: uint = 0;
		private const ET_AMMO: uint = 1;
		private const ET_DMG_WEAP: uint = 2;
		private const ET_DMG_ARMO: uint = 3;
		private const ET_TIMED_EFFECT: uint = 4;
		private const ET_COMPONENTS_LIST: uint = 5;
		private const ET_ITEM_DESCRIPTION: uint = 6;
		private const ET_LEGENDARY_AND_LEVEL: uint = 7;
		private const ET_ITEM_HEALTH: uint = 7;

		private var m_BlankEntryFillTarget: uint = 0;
		private var m_EntrySpacing: Number = -3.5;
		private var m_EntrySpacingChanged: Boolean = false;
		private var m_EntryCount: int = 0;
		private var m_BottomUp: Boolean = true;

		public function ItemCard()
		{
			super();
			this._InfoObj = new Array();
			this._showItemDesc = true;
			this._showValueEntry = true;
			this.bItemHealthEnabled = true;
		}

		public function set blankEntryFillTarget(param1: uint): void
		{
			this.m_BlankEntryFillTarget = param1;
		}

		public function get blankEntryFillTarget(): uint
		{
			return this.m_BlankEntryFillTarget;
		}

		public function set entrySpacing(param1: Number): *
		{
			this.m_EntrySpacing = param1;
			this.m_EntrySpacingChanged = true;
		}

		public function get entryCount(): int
		{
			return this.m_EntryCount;
		}

		public function get entrySpacing(): Number
		{
			return this.m_EntrySpacing;
		}

		public function set bottomUp(param1: Boolean): *
		{
			this.m_BottomUp = param1;
		}

		public function get bottomUp(): Boolean
		{
			return this.m_BottomUp;
		}

		public function get InfoObj(): Array
		{
			return this._InfoObj;
		}

		public function set InfoObj(param1: Array): *
		{
			this._InfoObj = param1;
		}

		public function set showItemDesc(param1: Boolean): *
		{
			this._showItemDesc = param1;
		}

		public function get showItemDesc(): Boolean
		{
			return this._showItemDesc;
		}

		public function set showValueEntry(param1: Boolean): *
		{
			this._showValueEntry = param1;
		}

		public function get showValueEntry(): Boolean
		{
			return this._showValueEntry;
		}

		public function onDataChange(): *
		{
			SetIsDirty();
		}

		override public function redrawUIComponent(): void
		{
			var HasDMG_WEAP: Boolean = false;
			var HasDMG_ARMO: Boolean = false;
			var entries: Vector.<ItemCard_Entry> = new Vector.<ItemCard_Entry>();

			super.redrawUIComponent();
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}

			var idx: int = this._InfoObj.length - 1;
			while (idx >= 0)
			{
				switch (this._InfoObj[idx].text)
				{
					case ItemCard_MultiEntry.DMG_WEAP_ID:
						HasDMG_WEAP = HasDMG_WEAP || ItemCard_MultiEntry.IsEntryValid(this._InfoObj[idx]);
						break;

					case ItemCard_MultiEntry.DMG_ARMO_ID:
						HasDMG_ARMO = HasDMG_ARMO || ItemCard_MultiEntry.IsEntryValid(this._InfoObj[idx]);
						break;

					default:
						if (this._InfoObj[idx].showAsDescription != true)
						{
							var entryType: uint = this.GetEntryType(this._InfoObj[idx]);
							var newEntry: ItemCard_Entry = this.CreateEntry(entryType);
							if (newEntry != null)
							{
								newEntry.PopulateEntry(this._InfoObj[idx]);
								entries.push(newEntry);
							}
						}
				}
				idx--;
			}

			if (HasDMG_WEAP)
			{
				var weapEntry: ItemCard_MultiEntry = this.CreateEntry(this.ET_DMG_WEAP) as ItemCard_MultiEntry;
				if (weapEntry != null)
				{
					weapEntry.PopulateMultiEntry(this._InfoObj, ItemCard_MultiEntry.DMG_WEAP_ID);
					entries.push(weapEntry);
				}
			}

			if (HasDMG_ARMO)
			{
				var armoEntry: ItemCard_MultiEntry = this.CreateEntry(this.ET_DMG_ARMO) as ItemCard_MultiEntry;
				if (armoEntry != null)
				{
					armoEntry.PopulateMultiEntry(this._InfoObj, ItemCard_MultiEntry.DMG_ARMO_ID);
					entries.push(armoEntry);
				}
			}

			var descArray: Array = new Array();
			if (this._showItemDesc)
			{
				for each(var entry: Object in this._InfoObj)
				{
					if (entry.showAsDescription == true)
					{
						descArray.push(entry);
					}
				}

				if (descArray.length > 0)
				{
					var descEntry: ItemCard_DescriptionEntry = this.CreateEntry(this.ET_ITEM_DESCRIPTION) as ItemCard_DescriptionEntry;
					if (descEntry != null)
					{
						descEntry.PopulateEntries(descArray);
						entries.push(descEntry);
					}
				}
			}

			this.FillBlankEntries(entries);
			if (!this.m_BottomUp)
			{
				entries.reverse();
			}

			this.m_EntryCount = 0;
			var entryY: Number = 0;
			idx = 0;
			while (idx < entries.length)
			{
				addChild(entries[idx]);
				if (entries[idx] is ItemCard_MultiEntry)
				{
					this.m_EntryCount = this.m_EntryCount + (entries[idx] as ItemCard_MultiEntry).entryCount;
				}
				else if (entries[idx] is ItemCard_ComponentsEntry)
				{
					this.m_EntryCount = this.m_EntryCount + (entries[idx] as ItemCard_ComponentsEntry).entryCount;
				}
				else
				{
					this.m_EntryCount++;
				}

				if (this.m_BottomUp)
				{
					if (entryY < 0)
					{
						entryY = entryY - this.m_EntrySpacing;
					}
					entryY = entryY - entries[idx].height;
					entries[idx].y = entryY;
				}
				else
				{
					entries[idx].y = entryY;
					entryY = entryY + (entries[idx].height + this.m_EntrySpacing);
				}
				idx++;
			}
		}

		private function FillBlankEntries(param1: Vector.<ItemCard_Entry>): void
		{
			var _loc5_: ItemCard_Entry = null;
			var _loc6_: uint = 0;
			var _loc2_: int = 0;
			var _loc3_: int = param1.length;
			var _loc4_: int = 0;
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
					_loc5_.PopulateEntry(
					{
						"text": "",
						"value": ""
					});
					param1.unshift(_loc5_);
					_loc6_++;
				}
			}
		}

		private function GetEntryType(param1: Object): uint
		{
			var entryType: uint = this.ET_STANDARD;
			if (param1.damageType == 10)
			{
				entryType = this.ET_AMMO;
			}
			else if (param1.duration != null && param1.duration > 0)
			{
				entryType = this.ET_TIMED_EFFECT;
			}
			else if (param1.components is Array && param1.components.length > 0)
			{
				entryType = this.ET_COMPONENTS_LIST;
			}
			return entryType;
		}

		private function CreateEntry(param1: uint): ItemCard_Entry
		{
			var newEntry: ItemCard_Entry = null;
			switch (param1)
			{
				case this.ET_STANDARD:
					newEntry = new ItemCard_StandardEntry();
					break;
				case this.ET_AMMO:
					newEntry = new ItemCard_AmmoEntry();
					break;
				case this.ET_DMG_WEAP:
				case this.ET_DMG_ARMO:
					newEntry = new ItemCard_MultiEntry();
					if (this.m_EntrySpacingChanged)
					{
						(newEntry as ItemCard_MultiEntry).entrySpacing = this.m_EntrySpacing;
					}
					break;
				case this.ET_TIMED_EFFECT:
					newEntry = new ItemCard_TimedEntry();
					break;
				case this.ET_COMPONENTS_LIST:
					newEntry = new ItemCard_ComponentsEntry();
					break;
				case this.ET_ITEM_DESCRIPTION:
					newEntry = new ItemCard_DescriptionEntry();
					break;
				case this.ET_ITEM_HEALTH:
					newEntry = new ItemCard_ItemHealthEntry();
					break;
			}
			return newEntry;
		}

		public function HideItemHealth(): *
		{
			this.bItemHealthEnabled = false;
		}
	}
}