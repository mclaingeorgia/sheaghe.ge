class Faq < ActiveRecord::Base

  validates_presence_of :question, :answer

  # Fields to be translated
  translates :question, :answer

end
