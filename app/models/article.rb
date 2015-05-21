class Article < ActiveRecord::Base
	has_many :comments, dependent: :destroy
	validate :title, presence: true

	self.per_page = 10
end
