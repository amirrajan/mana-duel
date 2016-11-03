class Shield < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:red]
  end
end
