class UltimateDefense < Spell
  def initialize
    @type = :defense
  end

  def sequence
    [:blue, :yellow, :red, :indigo]
  end
end
