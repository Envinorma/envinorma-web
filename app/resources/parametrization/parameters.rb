# frozen_string_literal: true

module Parametrization
  module Parameters
    include Conditions
    include Warnings

    def prepare_ams(ams, classements)
      # For each AM, it maps classements matching on rubrique and regime
      # and transforms the AM based on the parameters of the classements.
      classements_by_am_id = AM.from_classements(classements, match_on_alineas: true)
      ams.map { |am| transform(am, classements_by_am_id.fetch(am.id, [])) }
    end

    private

    def transform(arrete_ministeriel, classements)
      parameters = classements_parameter_hash(classements)
      apply_parameter_values_to_am(arrete_ministeriel, parameters)
    end

    def classements_parameter_hash(classements)
      return {} if classements.empty?

      if classements.length > 1
        # To avoid ambiguity, we only keep parameters that have the same values.
        hashes = classements.map { |classement| parameter_hash(classement) }
        return keep_identical_values(hashes)
      end

      classement = classements[0]
      parameter_hash(classement)
    end

    def keep_identical_values(hashes)
      # builds merged hash with all keys and values of the first hash if
      # all hashes have the same value for the key.
      hashes.reduce { |merged, hash| merged.keys.index_with { |k| merged[k] == hash[k] ? merged[k] : nil }.compact }
    end

    def parameter_hash(classement)
      date = date_key(classement.regime)
      {
        'regime' => classement.regime,
        'alinea' => classement.alinea,
        'rubrique' => classement.rubrique,
        'quantite-rubrique' => classement.float_volume,
        'date-d-installation' => classement.date_mise_en_service,
        date => classement.date_autorisation
      }.compact
    end

    def date_key(regime)
      return 'date-d-autorisation' if regime == 'A'

      return 'date-d-declaration' if regime == 'D'

      'date-d-enregistrement'
    end

    def apply_parameter_values_to_am(arrete_ministeriel, parameters)
      arrete_ministeriel.data.sections = arrete_ministeriel.data.sections.map do |section|
        apply_parameter_to_section(section, parameters)
      end
      arrete_ministeriel
    end

    def apply_parameter_to_section(section, parameters)
      # Changes `section.applicability` depending on `parameters` and `section.parametrization`.
      # `parameters` is a hash containing the values of the dates, rubriques, etc. if known
      # `section.parametrization` contains conditions of inapplicability, conditions of modification,
      # and warnings. If any condition is met by parameters, `section.applicability` is set accordingly.
      warnings = section.parametrization.warnings.dup

      inapplicable, inapplicability_warnings = handle_inapplicabilities(section, parameters)

      if inapplicable
        section.applicability.warnings = warnings + inapplicability_warnings
        return section
      end

      modified, modified_warnings = handle_modifications(section, parameters)

      if modified
        section.applicability.warnings = warnings + modified_warnings
        return section
      end

      # If no modification or inapplicability were met, we recurse in subsections
      section.sections.each do |subsection|
        apply_parameter_to_section(subsection, parameters)
      end
      section.applicability.warnings = warnings + inapplicability_warnings + modified_warnings
      section
    end

    def handle_inapplicabilities(section, parameters)
      warnings = []
      section.parametrization.potential_inapplicabilities.each do |inapplicability|
        condition = inapplicability.condition
        if satisfied?(condition, parameters)
          deactivate_alineas(section, inapplicability.alineas, inapplicability.subsections_are_inapplicable)
          return [true, [inapplicability_warning(inapplicability)]]
        elsif potentially_satisfied?(condition, parameters)
          warnings << potentially_satisfied_warning(condition, false, inapplicability.alineas)
        end
      end
      [false, warnings]
    end

    def handle_modifications(section, parameters)
      warnings = []
      section.parametrization.potential_modifications.each do |modification|
        if satisfied?(modification.condition, parameters)
          apply_modification(section, modification)
          return [true, [modification_warning(modification)]]
        elsif potentially_satisfied?(modification.condition, parameters)
          warnings << potentially_satisfied_warning(modification.condition, true)
        end
      end
      [false, warnings]
    end

    def apply_modification(section, modification)
      # Changes `section` content with `modification`.
      previous_version = section.dup
      section.sections = modification.new_version.sections
      section.outer_alineas = modification.new_version.outer_alineas
      section.title = modification.new_version.title
      section.applicability.modified = true
      section.applicability.previous_version = previous_version
    end

    def deactivate_alineas(section, target_alineas, subsections_are_inapplicable)
      # Deactivates alineas in `section` whose index is in `target_alineas`.
      # `target_alineas` is an array of alineas ids. If nil, all alineas are deactivated (also in
      # children sections).
      section.applicability.active = false if target_alineas.blank?
      section.outer_alineas.each_with_index do |alinea, index|
        alinea.active = target_alineas.present? && target_alineas.exclude?(index)
      end

      return unless subsections_are_inapplicable

      section.sections.each { |subsection| deactivate_alineas(subsection, nil, true) }
    end
  end
end
