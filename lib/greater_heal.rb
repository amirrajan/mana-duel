class GreaterHeal < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:dog, :tiger, :dragon, :rat]
  end

  def damage
    -2
  end
end
