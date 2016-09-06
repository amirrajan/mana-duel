class UltimateDefense < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:ox, :dog, :dragon, :rat]
  end
end
