class Heal < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:yellow, :violet, :indigo]
  end

  def damage
    -1
  end
end
