module CurateND
  module AdminConstraint

    module_function

    def matches?(request)
      current_user = request.env.fetch('warden').user
      !!admin_usernames.include?(current_user.username)
    rescue KeyError, NoMethodError
      return false
    end

    def admin_usernames
      @admin_usernames ||= YAML.load(ERB.new(Rails.root.join('config/admin_usernames.yml').read).result)[Rails.env]['admin_usernames']
    end

  end
end
