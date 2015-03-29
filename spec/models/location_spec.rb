require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Location, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:location)).to be_valid
  end

  it 'is linked to one or several ads' do
    expect(FactoryGirl.build(:location)).to have_many(:ads)
  end

  it 'is linked to a user' do
    expect(FactoryGirl.build(:location)).to belong_to(:user)
  end

  it 'is invalid without a postal code' do
    expect(FactoryGirl.build(:location, postal_code: nil)).not_to be_valid
  end

  it 'is invalid without a latitude' do
    expect(FactoryGirl.build(:location, latitude: nil)).not_to be_valid
  end

  it 'is invalid without a longitude' do
    expect(FactoryGirl.build(:location, longitude: nil)).not_to be_valid
  end

  it 'has a latitude between -90 and 90' do
    expect(FactoryGirl.build(:location, latitude: -100)).not_to be_valid
    expect(FactoryGirl.build(:location, latitude: 100)).not_to be_valid
  end

  it 'has a longitude between -180 and 180' do
    expect(FactoryGirl.build(:location, longitude: -190)).not_to be_valid
    expect(FactoryGirl.build(:location, longitude: 190)).not_to be_valid
  end



end