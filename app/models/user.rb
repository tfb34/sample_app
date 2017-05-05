class User < ApplicationRecord
	before_save{self.email = email.downcase}
	validates(:name, presence: true, length: {maximum: 50})
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates(:email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive:false})

	has_secure_password# only requirement to work its magic is to have an attribute called password_digest, must add password _digest column to users table, so need to make another migration
	validates(:password, presence: true, length:{minimum:6})
end
