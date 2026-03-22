require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'guest can open sign up page' do
    get new_user_registration_path

    assert_response :success
    assert_select 'h2', 'Sign up'
  end

  test 'invalid sign up re-renders the form with errors' do
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          nickname: '',
          email: '',
          password: 'password',
          password_confirmation: 'mismatch'
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select '#error_explanation'
  end
end
