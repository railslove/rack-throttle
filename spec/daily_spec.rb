require File.dirname(__FILE__) + '/spec_helper'

describe Rack::Throttle::Daily do
  include Rack::Test::Methods

  before do
    def app
      @target_app ||= example_target_app
      @app ||= Rack::Throttle::Daily.new(@target_app, :max_per_day => 3)
    end
  end

  it "should be allowed if not seen this day" do
    get "/foo"
    last_response.body.should show_allowed_response
  end

  it "should be allowed if seen fewer than the max allowed per day" do
    2.times { get "/foo" }
    last_response.body.should show_allowed_response
  end

  it "should not be allowed if seen more times than the max allowed per day" do
    4.times { get "/foo" }
    last_response.body.should show_throttled_response
  end

  it "should be allowed if we are in a new day" do
    Time.stub!(:now).and_return(Time.local(2000,"jan",1,0,0,0))

    4.times { get "/foo" }
    last_response.body.should show_throttled_response

    forward_one_minute = Time.now + 60*60*24
    Time.stub!(:now).and_return(forward_one_minute)

    get "/foo"
    last_response.body.should show_allowed_response
  end
end