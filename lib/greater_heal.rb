class GreaterHeal < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:yellow, :violet, :red, :indigo]
  end

  def damage
    -2
  end
end
