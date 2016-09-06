class NextSequence
  def match_index_for command_history, sequence
    match_index = 0

    sequence.count.times do |i|
      match_index = i if sequence.take(i) == command_history.last(i)
    end

    match_index
  end

  def for_spell primary, assist, spell
    match_index = match_index_for primary, spell.sequence

    assist_match_index = match_index

    if spell.assist_sequence?
      assist_match_index = match_index_for assist, spell.assist_sequence
    end

    match_index = 0 if assist_match_index != match_index

    hash = {
      command: spell.sequence[match_index],
      countdown: spell.sequence.count - match_index,
      alternate_command: nil,
      alternate_countdown: nil
    }

    unless spell.alternate_sequence.empty?
      match_index = match_index_for primary, spell.alternate_sequence

      hash[:alternate_command] = spell.alternate_sequence[match_index]
      hash[:alternate_countdown] = spell.alternate_sequence.count - match_index
    end

    hash
  end

  def for command_history_for_team, spells
    primary = command_history_for_team[:primary]
    assist = command_history_for_team[:assist]

    sequence = {}
    by_spell = {}

    filtered_spells = spells.reject { |s| s.sequence.empty? }
    filtered_spells.each { |s| by_spell[s.class] = for_spell primary, assist, s }

    by_command = {}
    by_spell.each_key { |key| by_command[by_spell[key][:command]] = [] }
    filtered_spells.each { |s| by_command[s.sequence.first] = [] }

    by_spell.each_key do |key|
      entry = {}
      entry[:spell] = key
      entry[:countdown] = by_spell[key][:countdown]

      by_command[by_spell[key][:command]] << entry

      if by_spell[key][:alternate_command] && by_spell[key][:alternate_command] != by_spell[key][:command]
        entry = {}
        entry[:spell] = key
        entry[:countdown] = by_spell[key][:alternate_countdown]
        by_command[by_spell[key][:alternate_command]] << entry
      end
    end

    filtered_spells.each do |s|
      entry = {}
      entry[:spell] = s.class
      entry[:countdown] = s.sequence.count

      entry_for_class = by_command[s.sequence.first]
                        .map { |hash| hash[:spell] }
                        .include? s.class

      by_command[s.sequence.first] << entry unless entry_for_class
    end

    mins = {}

    by_spell.each_key do |key|
      mins[key] ||= { countdown: 99, of: key.new.sequence.count }
      mins[key][:countdown] = by_spell[key][:countdown] if by_spell[key][:countdown] < mins[key][:countdown]
    end

    sequence[:by_spell] = by_spell
    sequence[:by_command] = by_command
    sequence[:mins] = mins

    sequence
  end
end
