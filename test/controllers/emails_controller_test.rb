require 'test_helper'

class EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should reponse successfully" do
    post emails_url
    assert_response :success
  end
end
