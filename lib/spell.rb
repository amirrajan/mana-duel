class Spell
  attr_accessor :type

  def name
    self.class.to_s
  end

  def offensive?
    type == :attack
  end

  def damage
    0
  end

  def sequence
    []
  end

  def sequences
    all_sequences = []

    all_sequences << sequence

    all_sequences << alternate_sequence if alternate_sequence?

    all_sequences
  end

  def alternate_sequence
    []
  end

  def assist_sequence
    []
  end

  def assist_sequence?
    false
  end

  def alternate_sequence?
    false
  end

  def match? team
    unit = team[:primary]

    if alternate_sequence?
      return sequence_match?(unit, sequence) || sequence_match?(unit, alternate_sequence)
    end

    sequence_match?(unit, sequence)
  end

  def sequence_match? unit, for_sequence
    size = for_sequence.count

    for_sequence.reverse.take(size) == unit.reverse.take(size)
  end
end
