class LightningBolt < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:yellow, :violet, :violet, :yellow, :yellow]
  end

  def damage
    5
  end
end
