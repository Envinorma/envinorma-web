# frozen_string_literal: true

module Parametrization
  module Parameters
    include Conditions
    include Warnings

    def prepare_am(ams, classements)
      classements_by_am_cid = AM.from_classements(classements, true)
      ams.map { |am| transform(am, classements_by_am_cid.fetch(am.cid, [])) }
    end

    private

    def transform(arrete_ministeriel, classements)
      parameters = classements_parameter_dict(classements)
      apply_parameter_values_to_am(arrete_ministeriel, parameters)
    end

    def classements_parameter_dict(classements)
      return {} if classements.length != 1

      classement = classements[0]
      parameter_dict(classement)
    end

    def parameter_dict(classement)
      date = date_key(classement.regime)
      {
        'regime' => classement.regime,
        'alinea' => classement.alinea,
        'rubrique' => classement.rubrique,
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
      # TODO: comment this
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

      section.sections.each do |subsection|
        apply_parameter_to_section(subsection, parameters)
      end
      section.applicability.warnings = warnings + inapplicability_warnings + modified_warnings
      section
    end

    def handle_inapplicabilities(section, parameters)
      warnings = []
      section.parametrization.potential_inapplicabilities.each do |inapplicability|
        if satisfied?(inapplicability.condition, parameters)
          deactivate_alineas(section, inapplicability.alineas)
          return [true, [inapplicability_warning(inapplicability)]]
        elsif potentially_satisfied?(inapplicability.condition, parameters)
          warnings << potentially_satisfied_warning(inapplicability.condition, false)
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
      previous_version = section.dup
      section.sections = modification.new_version.sections
      section.outer_alineas = modification.new_version.outer_alineas
      section.title = modification.new_version.title
      section.applicability.modified = true
      section.applicability.previous_version = previous_version
    end

    def deactivate_alineas(section, target_alineas)
      section.applicability.active = false if target_alineas.blank?
      section.outer_alineas.each_with_index do |alinea, index|
        alinea.active = target_alineas.present? && target_alineas.exclude?(index)
      end

      return if target_alineas.present?

      section.sections.each { |subsection| deactivate_alineas(subsection, target_alineas) }
    end
  end
end
