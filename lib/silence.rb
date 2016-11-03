class Silence < Spell
  def sequence
    [:green, :indigo, :yellow]
  end

  def self.disables
    [:blue, :yellow, :violet, :green]
  end
end
