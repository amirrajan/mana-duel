class Amnesia < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:yellow, :red, :red]
  end
end
