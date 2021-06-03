package Components
{
	import Shared.GlobalFunc;
	import flash.display.MovieClip;

	public class ItemCard_MultiEntry extends ItemCard_Entry
	{
		public static const DMG_WEAP_ID: String = "$dmg";
		public static const DMG_ARMO_ID: String = "$dr";

		public var EntryHolder_mc: MovieClip;
		public var Background_mc: MovieClip;
		private var m_EntrySpacing: Number = 3.5;
		private var m_EntryCount: int = 0;

		public function ItemCard_MultiEntry()
		{
			super();
		}

		public static function IsEntryValid(param1: Object): Boolean
		{
			return param1.value > 0 || ShouldShowDifference(param1) && param1.text == DMG_ARMO_ID;
		}

		public function set entrySpacing(param1: Number): *
		{
			this.m_EntrySpacing = param1;
		}

		public function get entryCount(): int
		{
			return this.m_EntryCount;
		}

		public function PopulateMultiEntry(param1: Array, param2: String): *
		{
			while (this.EntryHolder_mc.numChildren > 0)
			{
				this.EntryHolder_mc.removeChildAt(0);
			}

			if (Label_tf != null)
			{
				GlobalFunc.SetText(Label_tf, param2, false);
			}

			this.m_EntryCount = 0;
			var entryY: Number = 0;
			var idx: uint = 0;
			while (idx < param1.length)
			{
				if (param1[idx].text == param2 && IsEntryValid(param1[idx]))
				{
					var newEntry: ItemCard_MultiEntry_Value = new ItemCard_MultiEntry_Value();
					newEntry.Icon_mc.gotoAndStop(param2 == DMG_WEAP_ID ? param1[idx].damageType + GlobalFunc.NUM_DAMAGE_TYPES : param1[idx].damageType);
					newEntry.PopulateEntry(param1[idx]);

					this.EntryHolder_mc.addChild(newEntry);
					this.m_EntryCount++;

					if (entryY > 0)
					{
						entryY = entryY + this.m_EntrySpacing;
					}
					newEntry.y = entryY;
					
					if (newEntry.Sizer_mc != null)
					{
						entryY = entryY + newEntry.Sizer_mc.height;
					}
					else
					{
						entryY = entryY + newEntry.height;
					}
				}
				idx++;
			}

			if (this.Background_mc != null && this.m_EntryCount > 1)
			{
				this.Background_mc.height = entryY;
			}
		}
	}
}