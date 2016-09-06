class ActivatedSpells < Array
  def initialize turn, spell_registry
    @turn = turn
    @spell_registry = spell_registry
  end

  def init_spells command_history
    spells(command_history).each { |s| self << s }
  end

  def spells command_history
    unit_combinations.map do |combo|
      activate_spell_for(combo[:team],
                         combo[:primary_unit],
                         combo[:assist_unit],
                         combo[:opposing_team],
                         command_history)
    end.reject { |report| report[:spell].is_a? Wait }
  end

  def unit_combinations
    [
      {
        team: :a,
        primary_unit: :left,
        assist_unit: :right,
        opposing_team: :b
      },
      {
        team: :a,
        primary_unit: :right,
        assist_unit: :left,
        opposing_team: :b
      },
      {
        team: :b,
        primary_unit: :left,
        assist_unit: :right,
        opposing_team: :a
      },
      {
        team: :b,
        primary_unit: :right,
        assist_unit: :left,
        opposing_team: :a
      }
    ]
  end

  def empty_summary
    {
      left: {
        command: '',
        spell: { name: '', nullified: false },
        restrictions: nil
      },
      right: {
        command: '',
        spell: { name: '', nullified: false },
        restrictions: nil
      }
    }
  end

  def summary command_history, enchantment_status_history
    summary = {}

    summary[:turn] = @turn
    summary[:a] = empty_summary
    summary[:b] = empty_summary

    unit_combinations.each do |combo|
      team = combo[:team]
      unit = combo[:primary_unit]
      opposing_team = combo[:opposing_team]

      summary[team][unit][:command] = command_history[team][unit].last

      report = find_spell team, unit

      next unless report

      summary[team][unit][:spell][:name] = report[:spell].name

      spell_nullified = nullified?(opposing_team, report[:spell])

      summary[team][unit][:spell][:nullified] = spell_nullified

      record_amnesia_usage summary,
                           report,
                           command_history,
                           team,
                           opposing_team

      record_paralysis_usage summary,
                             report,
                             command_history,
                             enchantment_status_history,
                             team,
                             opposing_team,
                             unit

      record_silence_usage summary,
                           report,
                           team,
                           opposing_team
    end

    invalidate_fast_lightning_on_same_turn summary

    summary
  end

  def invalidate_fast_lightning_on_same_turn summary
    [:a, :b].each do |team|
      if summary[team][:left][:spell][:name] == 'FastLightningBolt' &&
         summary[team][:right][:spell][:name] == 'FastLightningBolt'
        summary[team][:right][:spell][:name] = ''
      end
    end
  end

  def nullification_summary spell, team, opposing
    spell_casted = was_casted?(team, spell)

    is_reflected = was_casted?(opposing, Reflect)

    is_nullified = nullified?(opposing, spell.new)

    status = {
      apply_enchantment: true,
      is_reflected: is_reflected,
      target_team: opposing
    }

    status[:apply_enchantment] = false unless spell_casted

    if spell_casted && is_nullified && !is_reflected
      status[:apply_enchantment] = false
    end

    status[:target_team] = team if is_reflected

    status
  end

  def record_silence_usage summary,
                           report,
                           team,
                           opposing_team

    return unless report[:spell].is_a? Silence

    result = nullification_summary Silence, team, opposing_team

    return unless result[:apply_enchantment]

    target_team = result[:target_team]

    [:left, :right].each do |target|
      summary[target_team][target][:restrictions] = {
        commands: [:dragon, :rat, :ram, :wait],
        because_of: 'Silence'
      }
    end
  end

  def record_amnesia_usage summary,
                           report,
                           command_history,
                           team,
                           opposing_team

    return unless report[:spell].is_a? Amnesia

    result = nullification_summary Amnesia, team, opposing_team

    return unless result[:apply_enchantment]

    target_team = result[:target_team]

    [:left, :right].each do |target|
      summary[target_team][target][:restrictions] = {
        commands: [command_history[target_team][target].last],
        because_of: 'Amnesia'
      }
    end
  end

  def record_paralysis_usage summary,
                             report,
                             command_history,
                             enchantment_status_history,
                             team,
                             opposing_team,
                             unit

    return unless report[:spell].is_a? Paralysis

    result = nullification_summary Paralysis, team, opposing_team

    return unless result[:apply_enchantment]

    target_team = result[:target_team]

    target_unit = unit

    if enchantment_status_history.last[target_team][:left] == Paralysis
      target_unit = :left
    end

    if enchantment_status_history.last[target_team][:right] == Paralysis
      target_unit = :right
    end

    restriction = [command_history[target_team][target_unit].last]

    restriction = [:tiger] if restriction == [:ox]
    restriction = [:dog] if restriction == [:snake]
    restriction = [:dragon] if restriction == [:rat]

    summary[target_team][target_unit][:restrictions] = {
      commands: restriction,
      because_of: 'Paralysis'
    }
  end

  def find_spell team, unit
    select { |s| s[:from] == team && s[:from_unit] == unit }.first
  end

  def was_casted? team, spell
    was_casted_by_unit?(team, :left, spell) || was_casted_by_unit?(team, :right, spell)
  end

  def was_casted_by_unit? team, unit, spell
    found_spell = find_spell team, unit

    return false unless found_spell

    return found_spell[:spell].is_a? spell
  end

  def activate_spell_for team,
                         primary_unit,
                         assist_unit,
                         opposing_team,
                         command_history

    team_commands = {
      primary: command_history[team][primary_unit],
      assist: command_history[team][assist_unit]
    }

    sign = command_history[team][primary_unit]
    spell = spell_match_for team_commands

    activate_spell = {
      from: team,
      from_unit: primary_unit,
      sign: sign.last,
      spell: spell,
      turn: @turn
    }

    if spell.offensive?
      activate_spell.merge(to: opposing_team)
    else
      activate_spell.merge(to: team)
    end
  end

  def spell_match_for team_command
    default = @spell_registry.select { |spell| spell.is_a? Wait }.first

    @spell_registry
      .select { |spell| spell.match? team_command }
      .first || default
  end

  def nullification_exlusions
    {
      Shield => [
        Seppuku, FastLightningBolt, LightningBolt,
        LightWounds, HeavyWounds, Shield,
        Sokushi, Amnesia, Upheaval, Reflect, Paralysis, Silence
      ],
      Reflect => [Shock, Sokushi],
      CounterSpell => [Shock, Sokushi],
      UltimateDefense => []
    }
  end

  def nullified? for_team, for_spell
    nullification_exlusions
      .each_key
      .map { |by_spell| nullified_by? by_spell, for_team, for_spell }
      .any?
  end

  def nullified_by? by_spell, for_team, for_spell
    return false if for_spell.type == :defense

    cant_nullify = nullification_exlusions[by_spell]

    return false if cant_nullify.include? for_spell.class

    any? { |report| report[:spell].is_a?(by_spell) && report[:to] == for_team }
  end

  def spells_nullified_by by_spell, for_team
    select do |report|
      report[:to] == for_team &&
        nullified_by?(by_spell, report[:to], report[:spell]) &&
        !report[:spell].is_a?(by_spell)
    end
  end

  def spells_nullified for_team
    nullification_exlusions
      .each_key
      .map { |by_spell| spells_nullified_by(by_spell, for_team) }
      .flatten
  end

  def spells_targeting team
    select { |report| report[:to] == team }
  end

  def spell_already_casted? past_reports, from_team, spell
    past_reports.any? do |report|
      report[:spell].is_a?(spell) && report[:from] == from_team
    end
  end

  def usable_spells for_team, opposing_team, past_reports
    filtered = spells_targeting(for_team) - spells_nullified(for_team)

    # special logic for fast lightning, can only be casted once per game
    fast_lighting_casted = spell_already_casted? past_reports,
                                                 opposing_team,
                                                 FastLightningBolt

    fast_lightning_count = filtered.count do |report|
      report[:spell].is_a?(FastLightningBolt) && report[:from] == opposing_team
    end
    # end special logic for fast lightning

    filtered.select do |report|
      usable = true

      if report[:spell].is_a? FastLightningBolt
        usable = !fast_lighting_casted

        if usable && fast_lightning_count == 2
          usable = report[:from_unit] == :left
        end
      end

      usable
    end
  end

  def usable_enchantments for_team, opposing_team, past_reports
    usable_spells(for_team,
                  opposing_team,
                  past_reports)
      .select { |r| enchantments.include? r[:spell].class }
  end

  def enchantments
    [Amnesia, Upheaval]
  end

  def total_damage_for team, opposing_team, past_reports
    damage_for usable_spells(team, opposing_team, past_reports)
  end

  def damage_for spells
    spells.map { |report| report[:spell].damage }
          .inject(:+) || 0
  end

  def total_reflected_damage_for team
    damage_for spells_nullified_by(Reflect, team)
  end
end
