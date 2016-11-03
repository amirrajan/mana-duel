=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = [blue, blue]
(stab) = orange
nothing () = Wait
=end

class Sokushi < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:red, :indigo, :red, :violet,
     :green, :green, :green, :yellow]
  end

  def damage
    100
  end
end
