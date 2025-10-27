require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: {
        user: {
          email_address: "newuser@u.northwestern.edu",
          username: "newuser",
          phone_number: "8475550000",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to profile_url
  end

  test "should reject invalid email domain" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          email_address: "invalid@example.com",
          username: "invaliduser",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
