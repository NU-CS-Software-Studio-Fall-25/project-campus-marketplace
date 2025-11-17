require "test_helper"
require "omniauth"

class UserTest < ActiveSupport::TestCase
  test "creates a new user from Google data when email is new" do
    auth = google_auth_hash(uid: "google-123", info: { email: "fresh_student@u.northwestern.edu", first_name: "Fresh", last_name: "Student" })

    assert_difference("User.count", 1) do
      @user = User.from_google(auth)
    end

    assert_equal "fresh_student@u.northwestern.edu", @user.email_address
    assert_equal "google-123", @user.google_uid
    assert_not_nil @user.confirmed_at
    assert @user.password_digest.present?
  end

  test "links Google account to existing local profile" do
    user = users(:one)
    auth = google_auth_hash(uid: "google-321", info: { email: user.email_address })

    assert_no_difference("User.count") do
      @linked_user = User.from_google(auth)
    end

    assert_equal user, @linked_user
    assert_equal "google-321", user.reload.google_uid
  end

  test "finds an existing user by Google UID on repeat login" do
    user = users(:one)
    user.update!(google_uid: "persistent-google-id")

    auth = google_auth_hash(uid: "persistent-google-id", info: { email: "different@u.northwestern.edu" })

    assert_no_difference("User.count") do
      @logged_user = User.from_google(auth)
    end

    assert_equal user, @logged_user
  end

  private
    def google_auth_hash(overrides = {})
      default = {
        provider: "google_oauth2",
        uid: "test-uid",
        info: {
          email: "test@u.northwestern.edu",
          first_name: "Test",
          last_name: "User",
          name: "Test User"
        },
        credentials: {
          token: "token",
          refresh_token: "refresh",
          expires_at: 1.hour.from_now.to_i
        }
      }

      OmniAuth::AuthHash.new(default.deep_merge(overrides))
    end
end
