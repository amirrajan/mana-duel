class Seppuku < Spell
  def initialize
    @type = :self
  end

  def damage
    15
  end

  def match? team
    (team[:primary].last == :orange && team[:assist].last == :orange) ||
      (team[:primary].last == :red && team[:assist].last == :red)
  end
end
