require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do 
  	get signup_path
  	assert_no_difference 'User.count' do #basically execute the block and check that count does not change
  		post users_path, params: {user: {name: "",
  			email: "user@invalid",
  			password: "foo",
  			password_confirmation: "bar"}}
  	end
  	assert_template 'users/new' #checks if failed submission re-renders the new action
  end

  test "valid signup information" do
  	get signup_path
  	assert_difference 'User.count', 1 do 
  		post users_path, params: {user: {name: "Jimin",
  			email: "chimchim@gmail.com",
  			password: "chimchim",
  			password_confirmation: "chimchim"}}  		
  	end
  	follow_redirect!
  	assert_template 'users/show'
    assert is_logged_in?
  end
end
