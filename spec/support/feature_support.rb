module FeatureSupport
  def with_javascript?
    @example.metadata[:js] || @example.metadata[:javascript]
  end

  def login_as(user)
    user.reload # because the user isn't re-queried via Warden
    super(user, scope: :user, run_callbacks: false)
  end

  def expect_to_create_activities
    expect {
      yield
    }.to change { ActivityEngine::Activity.count }
  end

  module_function
  def options(default = {type: :feature})
    if ENV['JS']
      Capybara.javascript_driver = default.fetch(:javascript_driver, :poltergeist_debug)
      default[:js] = true
    else
      Capybara.javascript_driver = default.fetch(:javascript_driver, :poltergeist)
    end

    if ENV['LOCAL']
      Capybara.current_driver = default.fetch(:javascript_driver, :poltergeist_debug)
    end
    default
  end

end
