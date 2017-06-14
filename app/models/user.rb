class User < ApplicationRecord
	attr_accessor :remember_token, :activation_token, :reset_token
  
  before_create :create_activation_digest
	#before_save{self.email = email.downcase}
  before_save :downcase_email
	validates(:name, presence: true, length: {maximum: 50})
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates(:email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive:false})

	has_secure_password# only requirement to work its magic is to have an attribute called password_digest, must add password _digest column to users table, so need to make another migration
	validates(:password, presence: true, length:{minimum:6}, allow_nil: true)
  
  #this association indicates that each instance of the model has 0+ instances of another model
  #has_many :posts
  has_many :microposts, dependent: :destroy

	  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  #Why use the prefix User in User.new_token and other methods? clarity
  #Returns a random token
  def User.new_token
  	SecureRandom.urlsafe_base64
  end
#Remembers a user in the database for persistent sessions
  def remember
  	self.remember_token = User.new_token
  	update_attribute(:remember_digest, User.digest(remember_token))
  end

  #Returns true if the given token matches the digest
 # def authenticated?(remember_token)
  #	return false if remember_digest.nil?
  #	BCrypt::Password.new(remember_digest).is_password?(remember_token)
  #end
  
#Returns true if the given token matches the digest
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  #forgets a user
  def forget
  	update_attribute(:remember_digest, nil)
  end

    # Activates an account.
  def activate
    #update_attribute(:activated,    true)
    #update_attribute(:activated_at, Time.zone.now)
    #avoid hitting up the database twice
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  #Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  #Sends password reset email
  def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
  end

# Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago # reads as password reset sent earlier than 2 hours ago
  end

  #Defines a proto-feed
  #see "following users" for the full implementation
  def feed
    Micropost.where("user_id = ?", id)
  end

  private

#converts email to all lower-case.
  def downcase_email
    #self.email = email.downcase
    email.downcase!
  end
#creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
