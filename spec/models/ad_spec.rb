require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Ad, :type => :model do

  after(:each){
    image_paths = %w(tmp.jpg tmp.txt)
    image_paths.each do |image_path|
      path = Rails.root.join(image_path)
      if File.exist?(path)
        File.delete(path)
      end
    end
  }

  BUFFER = ('a' * 1024).freeze

  it 'has a valid factory' do
    expect(FactoryGirl.create(:ad)).to be_valid
  end

  it 'is linked to a location' do
    expect(FactoryGirl.build(:ad)).to belong_to(:location)
  end

  it 'is linked to an item' do
    expect(FactoryGirl.build(:ad)).to belong_to(:item)
  end

  it 'is invalid without a title' do
    expect(FactoryGirl.build(:ad, title: nil)).not_to be_valid
  end

  it 'is invalid without a number of items' do
    expect(FactoryGirl.build(:ad, number_of_items: nil)).not_to be_valid
  end

  it 'is invalid without a linked location' do
    expect(FactoryGirl.build(:ad, location: nil)).not_to be_valid
  end

  it 'is invalid without a linked item' do
    expect(FactoryGirl.build(:ad, item: nil)).not_to be_valid
  end

  it 'is invalid without a description' do
    expect(FactoryGirl.build(:ad, description: nil)).not_to be_valid
  end

  it 'is invalid without a is_giving boolean' do
    expect(FactoryGirl.build(:ad, is_giving: nil)).not_to be_valid
  end

  it 'is invalid with an image too big (more than 5MB)' do
    # Generating a 10M file
    File.open('tmp.jpg', 'wb') { |f| 10.kilobytes.times { f.write BUFFER } }
    expect(FactoryGirl.build(:ad, image: File.open(Rails.root.join('tmp.jpg')))).not_to be_valid
  end

  it 'is invalid if image is not an image file' do
    # Generating a simple text file
    File.open('tmp.txt', 'wb') { |f| f.write BUFFER }
    expect(FactoryGirl.build(:ad, image: File.open(Rails.root.join('tmp.txt')))).not_to be_valid
  end

end