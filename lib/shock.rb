class Shock < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:orange]
  end

  def damage
    1
  end
end
