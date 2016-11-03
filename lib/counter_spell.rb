class CounterSpell < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:indigo, :red, :red]
  end

  def alternate_sequence
    [:indigo, :indigo, :green]
  end

  def alternate_sequence?
    true
  end
end
