require 'roo'
require 'csv'

class Article < ActiveRecord::Base
	attr_accessible :title, :content
	has_many :comments, dependent: :destroy
	validate :title, presence: true

	self.per_page = 10

	def self.to_xlsx(options = {})
		CSV.generate(options) do | csv |
			csv << column_names
			all.each do | article |
				csv << article.attributes.values_at(*column_names)
			end
		end
	end

	def self.import(file)
	  spreadsheet = open_spreadsheet(file)
	  if !spreadsheet then
	  	false
	  else
	  	header = spreadsheet.row(1)
	  	(2..spreadsheet.last_row).each do |i|
		    row = Hash[[header, spreadsheet.row(i)].transpose]
		    article = find_by_id(row["id"]) || new
		    article.attributes = row.to_hash.slice(*accessible_attributes)
		    article.save!
	  	end
	  	true
	  end
	end

	def self.open_spreadsheet(file)
	  case File.extname(file.original_filename)
	  when ".xlsx" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
	  else false
	  end
	end
end
