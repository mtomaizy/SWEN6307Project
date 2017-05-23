require 'test_helper'

class ProgrammsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @programm = programms(:one)
  end

  test "should get index" do
    get programms_url
    assert_response :success
  end

  test "should get new" do
    get new_programm_url
    assert_response :success
  end

  test "should create programm" do
    assert_difference('Programm.count') do
      post programms_url, params: { programm: { description: @programm.description, mingrade: @programm.mingrade, name: @programm.name, university: @programm.university } }
    end

    assert_redirected_to programm_url(Programm.last)
  end

  test "should show programm" do
    get programm_url(@programm)
    assert_response :success
  end

  test "should get edit" do
    get edit_programm_url(@programm)
    assert_response :success
  end

  test "should update programm" do
    patch programm_url(@programm), params: { programm: { description: @programm.description, mingrade: @programm.mingrade, name: @programm.name, university: @programm.university } }
    assert_redirected_to programm_url(@programm)
  end

  test "should destroy programm" do
    assert_difference('Programm.count', -1) do
      delete programm_url(@programm)
    end

    assert_redirected_to programms_url
  end
end
