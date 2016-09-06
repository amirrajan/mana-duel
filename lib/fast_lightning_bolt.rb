class FastLightningBolt < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:rat, :dog, :dog, :ox]
  end

  def assist_sequence
    [:ox]
  end

  def damage
    5
  end

  def match? team
    super && team[:assist].last == :ox
  end
end
