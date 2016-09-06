class LightningBolt < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:dog, :tiger, :tiger, :dog, :dog]
  end

  def damage
    5
  end
end
