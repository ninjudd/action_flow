require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'action_view/test_case'
require 'ostruct'
require 'flow/helper'

module Flow

  class HelperTest < ActionView::TestCase
    tests Flow::Helper

    class TestController < ActionController::Base
      attr_accessor :url

      def initialize(url)
        self.request = ActionController::TestRequest.new
        self.url = ActionController::UrlRewriter.new(request, url)
      end

      def context
        @context ||= OpenStruct.new(:state=>'state', :key=>'key')
      end

    end

    def setup
      @controller = TestController.new({:controller=>'text', :action=>'show'})
    end

    def test_flow_link_to
      text = 'text'
      options = {:option=>'value'}
      html_options = {:html_option=>'value'}
      with_route do
        result = flow_link_to(text, options, html_options)
        assert_match 'href="/test/next?', result, 'href missing'
        assert_match '_fk=key', result, 'flow key missng'
        assert_match '_fs=state', result, 'flow state missing'
        assert_match 'option=value', result
        assert_match 'html_option="value"', result
        assert_match '>text</a>', result, 'text missing'
      end
    end

    def test_flow_form_tag
      options = {:option=>'value'}
      html_options = {:html_option=>'value'}
      with_route do
        result = flow_form_tag(options, html_options)
        assert_match 'action="/test/next?', result, 'action missing'
        assert_match '_fk=key', result, 'flow key missng'
        assert_match '_fs=state', result, 'flow state missing'
        assert_match 'option=value', result
        assert_match 'html_option="value"', result
        assert_match 'method="post"', result
      end
    end

  private

    def with_route
      with_routing do |set|
        set.draw do |map|
          map.connect ':controller/:action/:id'
        end
        yield
      end
    end

    def protect_against_forgery?
      false
    end

  end # class HelperTest

end # module Flow
