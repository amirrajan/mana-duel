class Heal < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:dog, :tiger, :rat]
  end

  def damage
    -1
  end
end
