class FastLightningBolt < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:indigo, :yellow, :yellow, :blue]
  end

  def assist_sequence
    [:blue]
  end

  def damage
    5
  end

  def match? team
    super && team[:assist].last == :blue
  end
end
