class AvailableCommands
  def for spells
    spells.reject { |s| s.is_a? Wait }
          .map { |s| s.sequences.flatten }
          .flatten
          .uniq
  end
end
