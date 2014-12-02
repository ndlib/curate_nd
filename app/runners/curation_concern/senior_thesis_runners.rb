require 'hesburgh/lib/runner'

module CurationConcern
  module SeniorThesisRunners
    class New < Hesburgh::Lib::Runner
      delegate :repository, to: :context

      def run
        form = repository.build_new_senior_thesis_form
        callback(:success, form)
      end
    end

    class Create < Hesburgh::Lib::Runner
      delegate :repository, to: :context

      def run(attributes = {})
        form = repository.build_new_senior_thesis_form(attributes: attributes)
        senior_thesis = repository.submit_new_senior_thesis_form(form: form, current_user: context.current_user)

        if senior_thesis
          callback(:success, senior_thesis)
        elsif form.errors[:accept_contributor_agreement].present?
          callback(:unaccepted_contributor_agreement, form)
        else
          callback(:failure, form)
        end
      end
    end
  end
end
