require 'spec_helper'

describe LocalsController do
  render_views

  describe 'including a section with locals' do
    after :each do
      expect(response).to be_success
    end

    it 'passes the locals to the section' do
      get :section_with_locals
      expect(response.body.strip).to eql 'foo is bar fizz is buzz'
    end
  end
end
