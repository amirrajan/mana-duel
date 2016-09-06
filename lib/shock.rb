class Shock < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:ram]
  end

  def damage
    1
  end
end
