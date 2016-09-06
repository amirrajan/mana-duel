class Shield < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:dragon]
  end
end
