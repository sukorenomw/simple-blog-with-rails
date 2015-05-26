class User < ActiveRecord::Base
	has_many :articles, :dependent => :destroy
	has_many :comments, :dependent => :destroy

	attr_accessor :password
	attr_accessible :username, :email, :password, :password_confirmation, :captcha, :captcha_key
    before_save :add_salt_and_hash

	validates :username, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true
    validates_format_of :email, presence: true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    validates :password, presence: true, on: :create,
    length: { minimum: 6 },

    confirmation: true

    def self.check(params)
    	where("email=? or username=?",params,params)
    end

    def add_salt_and_hash
        unless password.blank?
            self.password_salt = BCrypt::Engine.generate_salt
            self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
        end
    end

    def self.authenticate(email, password)
		# user = User.check(email)
		user = find_by_username(email)
		if user && user.password_hash == BCrypt::Engine.hash_secret(password,user.password_salt)
			user
		else
			nil
		end
	end
end
