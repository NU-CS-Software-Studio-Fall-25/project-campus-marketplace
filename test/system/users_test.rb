require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "user signs up successfully" do
    visit new_user_path

    fill_in "First name", with: "Signup"
    fill_in "Last name", with: "Tester"
    fill_in "Northwestern email", with: "signup_tester@u.northwestern.edu"
    fill_in "Username", with: "signup_tester"
    fill_in "Phone number (optional)", with: "8475550202"
    fill_in "Password", with: "Password123!"
    fill_in "Password confirmation", with: "Password123!"
    click_button "Create Account"

    assert_text "Check your email to confirm your account before signing in."
    assert_text "Sign in"
  end

  test "user sees validation error for non-Northwestern email" do
    visit new_user_path

    fill_in "First name", with: "Bad"
    fill_in "Last name", with: "User"
    fill_in "Northwestern email", with: "bad@example.com"
    fill_in "Username", with: "baduser"
    fill_in "Password", with: "Password123!"
    fill_in "Password confirmation", with: "Password123!"
    click_button "Create Account"

    assert_text "must end with northwestern.edu or u.northwestern.edu"
  end
end
