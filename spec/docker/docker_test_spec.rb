require 'rails_helper'

RSpec.describe 'Docker Setup', type: :feature do
  it 'ensures the docker application can load and connect to services' do
    expect(ActiveRecord::Base.connection.active?).to be true
    expect(Rails.env).to eq('test')
  end
end
