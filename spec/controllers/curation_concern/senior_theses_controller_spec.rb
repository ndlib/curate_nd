# Generated via
#  `rails generate curate:work SeniorThesis`
require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module CurationConcern
  RSpec.describe SeniorThesesController, type: :controller do
    it_behaves_like 'is_a_curation_concern_controller', SeniorThesis, actions: :all

    context 'GET #new' do
      before { controller.runner = runner }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(yields: yields, callback_name: callback_name, run_with: nil, context: controller)
      end

      before { sign_in with_user('123', curation_concern: senior_thesis) }

      context 'when :success' do
        let(:callback_name) { :success }
        let(:senior_thesis) { SeniorThesis.new }
        let(:yields) { senior_thesis }
        it 'will render the "new" page' do
          get :new
          expect(assigns(:curation_concern)).to eq(senior_thesis)
          expect(response).to render_template('new')
        end
      end
    end
  end
end
