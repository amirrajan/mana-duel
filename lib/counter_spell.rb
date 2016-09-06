class CounterSpell < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:rat, :dragon, :dragon]
  end

  def alternate_sequence
    [:rat, :rat, :snake]
  end

  def alternate_sequence?
    true
  end
end
