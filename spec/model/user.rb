class User
  include Ripple::Document
  self.bucket_name = 'bench'
  self.key_on :id

  property :id, String
  property :text, String, short: 't'

  property :session_count,      Integer,  short: 'ss', default: 0

  property :coins,                       Integer, short: 'cn'
  property :cash,                        Integer, short: 'ch'
  property :prestige,                    Integer, short: 'pr'
  property :max_prestige,                Integer, short: 'mp'
  property :badges,                      Integer, short: 'sr',  default: 0
  property :badges_at_progression_reset, Integer, short: 'srr', default: 0
  property :flags,                       Integer, short: 'fl',  default: 0

  property :achievements,       Array,    short: 'ac', default: Proc.new {[]}
  property :mission,            Integer,  short: 'mi', default: 0

  property :started_scene_id,   String, short: 'se'

  property :unlock_chapter_at,  Time, short: 'uc'

  property :ad_transactions,    Array,   short: 'va', default: Proc.new {[]}

  property :unlimited_energy_tokens, Integer, short: 'ule', default: 0

  property :progression_reset_at, Date, short: 'rst'

  property :family_challenges_rewards_last_claimed_at,     Time, short: 'crlc'
  property :family_progression_rewards_last_score_claimed, Integer, short: 'cprlc'
  property :family_challenges_last_participated_at,        Integer, short: 'crlp'

  property :scenes_played,      Integer, short: 'stp', default: 0
  property :chapters_unlocked,  Integer, short: 'chu', default: 0
  property :scores_gained,      Integer, short: 'scg', default: 0

  property :energy,                        Hash, short: 'en'
  property :inventory,                     Hash, short: 'iv'
  property :soft_cap_inventory,            Hash, short: 'siv'
  property :iso_regions,                   Array, short: 'ia'
  property :daily_puzzle,                  Hash, short: 'dp'
  property :tournament,                    Hash, short: 'to'
  property :family_task_set,               Hash, short: 'fts'
  property :iso_inventory,                 Hash, short: 'isi'
  property :rewardable_iso_inventory,      Hash, short: 'risi'
  property :collection_inventory,          Hash, short: 'coll'
  property :flowers,                       Hash, short: 'mf'

  property :scenes,     Array, short: 'sc'
  property :iso_items,  Array, short: 'ii'
  property :orders,     Hash, short: 'or'
  property :events,     Hash, short: 'ev'

  def update_from_json(user_json)
    self.badges                      = user_json["badges"]
    self.coins                       = user_json["coins"]
    self.cash                        = user_json["cash"]
    self.prestige                    = user_json["prestige"]
    self.max_prestige                = user_json["max_prestige"]
    self.flags                       = user_json["flags"]
    self.achievements                = user_json["achievements"]
    self.mission                     = user_json["mission"]
    self.unlock_chapter_at           = user_json["unlock_chapter_at"]
    self.ad_transactions             = user_json["ad_transactions"]
    self.unlimited_energy_tokens     = user_json["unlimited_energy_tokens"]
    self.session_count               = user_json["session_count"]
    self.progression_reset_at        = user_json["progression_reset_at"]
    self.badges_at_progression_reset = user_json["badges_at_progression_reset"]
    self.scenes_played               = user_json["scenes_played"]
    self.chapters_unlocked           = user_json["chapters_unlocked"]
    self.scores_gained               = user_json["scores_gained"]

    self.energy             = user_json["energy"]
    self.inventory          = user_json["inventory"]
    self.soft_cap_inventory = user_json["soft_cap_inventory"]
    self.iso_regions        = user_json["regions"]
    self.iso_items          = user_json["iso_items"]
  end
end
