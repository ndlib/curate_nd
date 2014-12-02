class Repository
  def build_new_senior_thesis_form(options = {})
    NewSeniorThesisForm.new(options.fetch(:attributes, {}))
  end

  def submit_new_senior_thesis_form(options = {})
    current_user = options.fetch(:current_user)
    form = options.fetch(:form)
    operator = options.fetch(:operator) do
      lambda do |form, user|
        actor = CurationConcern::SeniorThesisActor.new(form.model, user, form.attributes)
        actor.create
        [form.model, actor.notification_messages]
      end
    end
    form.submit do |f|
      operator.call(f, current_user)
    end
  end
end
