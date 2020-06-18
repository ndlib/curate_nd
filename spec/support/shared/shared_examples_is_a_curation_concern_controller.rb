shared_examples 'is_a_curation_concern_controller' do |curation_concern_class, options = {}|
  actions = options.fetch(:actions, :all)

  CurationConcern::FactoryHelpers.load_factories_for(self, curation_concern_class)

  def self.optionally_include_specs(actions, action_name)
    normalized_actions = Array(actions).flatten.compact
    return true if normalized_actions.include?(:all)
    return true if normalized_actions.include?(action_name.to_sym)
    return true if normalized_actions.include?(action_name.to_s)
  end
  its(:curation_concern_type) { should eq curation_concern_class }

  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }
  before { sign_in user }

  def path_to_curation_concern
    # This fails with a ActionController::UrlGenerationError if the
    # curation_concern didn't save
    public_send("common_object_path", controller.curation_concern)
  end

  if optionally_include_specs(actions, :show)
    describe "#show" do
      context "my own private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name, user: user) }
        it "should show me the page" do
          get :show, id: a_work
          expect(response).to be_success
        end
      end
      context "someone elses private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name) }
        it "should show 401 Unauthorized" do
          get :show, id: a_work
          expect(response.status).to eq 401
          expect(response).to render_template(:unauthorized)
        end
      end
      context "someone elses public work" do
        let(:a_work) { FactoryGirl.create(public_work_factory_name) }
        it "should show me the page" do
          get :show, id: a_work
          expect(response).to be_success
        end
      end
    end
  end

  if optionally_include_specs(actions, :new)
    describe "#new" do
      context "my work" do

        render_views

        it "should show me the page" do
          get :new
          expect(response).to be_success

          expect(response.body).to have_tag('.promote-doi .form-group') do
            input_name = "#{curation_concern_class.model_name.singular}[doi_assignment_strategy]"
            if curation_concern_class.ancestors.include?(CurationConcern::RemotelyIdentifiedByDoi::Attributes)
              with_tag('input', with: { name: input_name, type: 'radio', value: CurationConcern::RemotelyIdentifiedByDoi::GET_ONE })
            end
            with_tag('input', with: { name: input_name, type: 'radio', value: CurationConcern::RemotelyIdentifiedByDoi::NOT_NOW } )
            with_tag('input', with: { name: input_name, type: 'radio', value: CurationConcern::RemotelyIdentifiedByDoi::ALREADY_GOT_ONE } )
            with_tag('input', with: { name: "#{curation_concern_class.model_name.singular}[existing_identifier]", type: 'text' } )
          end
        end
      end
    end
  end

  if optionally_include_specs(actions, :create)
    describe "#create" do
      it "should create a work" do
        allow(controller.curation_concern).to receive(:persisted?).and_return(true)
        controller.curation_concern.inner_object.pid = 'test:123'
        controller.actor = double(:create => true, notification_messages: [])

        post :create, accept_contributor_agreement: "accept"
        expect(response).to redirect_to path_to_curation_concern
      end
    end

    describe "#create failure" do
      it 'renders the form' do
        controller.actor = double(:create => false, notification_messages: [])
        post :create, accept_contributor_agreement: "accept"
        expect(response).to render_template('new')
      end
    end
  end

  if optionally_include_specs(actions, :edit)
    describe "#edit" do
      context "my own private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name, user: user) }
        it "should show me the page" do
          get :edit, id: a_work
          expect(response).to be_success
        end
      end
      context "someone elses private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name) }
        it "should show 401 Unauthorized" do
          get :edit, id: a_work
          expect(response.status).to eq 401
          expect(response).to render_template('errors/401')
        end
      end
      context "someone elses public work" do
        let(:a_work) { FactoryGirl.create(public_work_factory_name) }
        it "should show me the page" do
          get :edit, id: a_work
          expect(response.status).to eq 401
          expect(response).to render_template('errors/401')
        end
      end
    end
  end

  if optionally_include_specs(actions, :update)
    describe "#update" do
      let(:a_work) { FactoryGirl.create(default_work_factory_name, user: user) }
      it "should update the work " do
        controller.actor = double(:update => true, :visibility_changed? => false, notification_messages: [])
        patch :update, id: a_work
        expect(response).to redirect_to path_to_curation_concern
      end
      describe "changing rights" do
        it "should prompt to change the files access" do
          controller.actor = double(:update => true, :visibility_changed? => true, notification_messages: [])
          patch :update, id: a_work
          expect(response).to redirect_to confirm_curation_concern_permission_path(controller.curation_concern)
        end
      end
      describe "failure" do
        it "renders the form" do
          controller.actor = double(:update => false, :visibility_changed? => false, notification_messages: [])
          patch :update, id: a_work
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
