require "test_helper"

class BotControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get bot_index_url
    assert_response :success
  end
end
