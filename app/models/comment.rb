class Comment < ActiveRecord::Base
	attr_accessible :id, :content, :article_id, :user_id, :created_at, :update_at
	belongs_to :article
	belongs_to :user
end
