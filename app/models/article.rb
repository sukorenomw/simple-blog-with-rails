require 'roo'
require 'csv'

class Article < ActiveRecord::Base
	attr_accessible :id, :title, :content, :created_at, :updated_at, :user_id
	has_many :comments, dependent: :destroy
	belongs_to :user
	validate :title, presence: true
	validate :id, uniqueness: true


	self.per_page = 10
end
