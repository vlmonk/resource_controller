$:.reject! { |path| path.include? 'TextMate' }
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all

end



module Shoulda # :nodoc:
  module Controller # :nodoc:
    module HTML # :nodoc: all
      def self.included(other)
        other.class_eval do
          extend Shoulda::Controller::HTML::ClassMethods
        end
      end

      module ClassMethods
        def controller_name_from_class
          self.name.gsub(/Test/, '')
        end

        def make_show_html_tests(res)
          context "on GET to #{controller_name_from_class}#show" do
            setup do
              record = get_existing_record(res)
              parent_params = make_parent_params(res, record)
              get :show, parent_params.merge({ res.identifier => record.to_param })
            end

            if res.denied.actions.include?(:show)
              should_not_assign_to res.object
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash
            else
              should_assign_to res.object
              should_respond_with :success
              should_render_template :show
              should_not_set_the_flash
            end
          end
        end

        def make_edit_html_tests(res)
          context "on GET to #{controller_name_from_class}#edit" do
            setup do
              @record = get_existing_record(res)
              parent_params = make_parent_params(res, @record)
              get :edit, parent_params.merge({ res.identifier => @record.to_param })
            end

            if res.denied.actions.include?(:edit)
              should_not_assign_to res.object
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash
            else
              should_assign_to res.object
              should_respond_with :success
              should_render_template :edit
              should_not_set_the_flash
              should_render_a_form
              should "set @#{res.object} to requested instance" do
                assert_equal @record, assigns(res.object)
              end
            end
          end
        end

        def make_index_html_tests(res)
          context "on GET to #{controller_name_from_class}#index" do
            setup do
              record = get_existing_record(res) rescue nil
              parent_params = make_parent_params(res, record)
              get(:index, parent_params)
            end

            if res.denied.actions.include?(:index)
              should_not_assign_to res.object.to_s.pluralize
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash
            else
              should_respond_with :success
              should_assign_to res.object.to_s.pluralize
              should_render_template :index
              should_not_set_the_flash
            end
          end
        end

        def make_new_html_tests(res)
          context "on GET to #{controller_name_from_class}#new" do
            setup do
              record = get_existing_record(res) rescue nil
              parent_params = make_parent_params(res, record)
              get(:new, parent_params)
            end

            if res.denied.actions.include?(:new)
              should_not_assign_to res.object
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash
            else
              should_respond_with :success
              should_assign_to res.object
              should_not_set_the_flash
              should_render_template :new
              should_render_a_form
            end
          end
        end

        def make_destroy_html_tests(res)
          context "on DELETE to #{controller_name_from_class}#destroy" do
            setup do
              @record = get_existing_record(res)
              parent_params = make_parent_params(res, @record)
              delete :destroy, parent_params.merge({ res.identifier => @record.to_param })
            end

            if res.denied.actions.include?(:destroy)
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash

              should "not destroy record" do
                assert_nothing_raised { assert @record.reload }
              end
            else
              should_set_the_flash_to res.destroy.flash
              if res.destroy.redirect.is_a? Symbol
                should_respond_with res.destroy.redirect
              else
                should_redirect_to res.destroy.redirect
              end

              should "destroy record" do
                assert_raises(::ActiveRecord::RecordNotFound, "@#{res.object} was not destroyed.") do
                  @record.reload
                end
              end
            end
          end
        end

        def make_create_html_tests(res)
          context "on POST to #{controller_name_from_class}#create with #{res.create.params.inspect}" do
            setup do
              record = get_existing_record(res) rescue nil
              parent_params = make_parent_params(res, record)
              @count = res.klass.count
              post :create, parent_params.merge(res.object => res.create.params)
            end

            if res.denied.actions.include?(:create)
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash
              should_not_assign_to res.object

              should "not create new record" do
                assert_equal @count, res.klass.count
              end
            else
              should_assign_to res.object
              should_set_the_flash_to res.create.flash
              if res.create.redirect.is_a? Symbol
                should_respond_with res.create.redirect
              else
                should_redirect_to res.create.redirect
              end

              should "not have errors on @#{res.object}" do
                assert_equal [], pretty_error_messages(assigns(res.object)), "@#{res.object} has errors:"
              end
            end
          end
        end

        def make_update_html_tests(res)
          context "on PUT to #{controller_name_from_class}#update with #{res.create.params.inspect}" do
            setup do
              @record = get_existing_record(res)
              parent_params = make_parent_params(res, @record)
              put :update, parent_params.merge(res.identifier => @record.to_param, res.object => res.update.params)
            end

            if res.denied.actions.include?(:update)
              should_not_assign_to res.object
              should_redirect_to res.denied.redirect
              should_set_the_flash_to res.denied.flash
            else
              should_assign_to res.object
              should_set_the_flash_to(res.update.flash)
              if res.update.redirect.is_a? Symbol
                should_respond_with res.update.redirect
              else
                should_redirect_to res.update.redirect
              end

              should "not have errors on @#{res.object}" do
                assert_equal [], pretty_error_messages(assigns(res.object)), "@#{res.object} has errors:"
              end
            end
          end
        end
      end
    end
  end
end

module Shoulda # :nodoc:
  module Controller
    # A ResourceOptions object is passed into should_be_restful in order to configure the tests for your controller.
    #
    # Example:
    #   class UsersControllerTest < Test::Unit::TestCase
    #     fixtures :all
    #
    #     def setup
    #       ...normal setup code...
    #       @user = User.find(:first)
    #     end
    #
    #     should_be_restful do |resource|
    #       resource.identifier = :id
    #       resource.klass      = User
    #       resource.object     = :user
    #       resource.parent     = []
    #       resource.actions    = [:index, :show, :new, :edit, :update, :create, :destroy]
    #       resource.formats    = [:html, :xml]
    #
    #       resource.create.params = { :name => "bob", :email => 'bob@bob.com', :age => 13}
    #       resource.update.params = { :name => "sue" }
    #
    #       resource.create.redirect  = "user_url(@user)"
    #       resource.update.redirect  = "user_url(@user)"
    #       resource.destroy.redirect = "users_url"
    #
    #       resource.create.flash  = /created/i
    #       resource.update.flash  = /updated/i
    #       resource.destroy.flash = /removed/i
    #     end
    #   end
    #
    # Whenever possible, the resource attributes will be set to sensible defaults.
    #
    class ResourceOptions
      # Configuration options for the create, update, destroy actions under should_be_restful
      
      # Formats tested by #should_be_restful.  Defaults to [:html, :xml]
      VALID_FORMATS = [:html] unless defined?(VALID_FORMATS)


      # Actions tested by #should_be_restful
      VALID_ACTIONS = [:index, :show, :new, :edit, :create, :update, :destroy] unless defined?(VALID_ACTIONS) # :doc:

      class ActionOptions
        # String evaled to get the target of the redirection.
        # All of the instance variables set by the controller will be available to the
        # evaled code.
        #
        # Example:
        #   resource.create.redirect  = "user_url(@user.company, @user)"
        #
        # Defaults to a generated url based on the name of the controller, the action, and the resource.parents list.
        attr_accessor :redirect

        # String or Regexp describing a value expected in the flash.  Will match against any flash key.
        #
        # Defaults:
        # destroy:: /removed/
        # create::  /created/
        # update::  /updated/
        attr_accessor :flash

        # Hash describing the params that should be sent in with this action.
        attr_accessor :params
      end

      # Configuration options for the denied actions under should_be_restful
      #
      # Example:
      #   context "The public" do
      #     setup do
      #       @request.session[:logged_in] = false
      #     end
      #
      #     should_be_restful do |resource|
      #       resource.parent = :user
      #
      #       resource.denied.actions = [:index, :show, :edit, :new, :create, :update, :destroy]
      #       resource.denied.flash = /get outta here/i
      #       resource.denied.redirect = 'new_session_url'
      #     end
      #   end
      #
      class DeniedOptions
        # String evaled to get the target of the redirection.
        # All of the instance variables set by the controller will be available to the
        # evaled code.
        #
        # Example:
        #   resource.create.redirect  = "user_url(@user.company, @user)"
        attr_accessor :redirect

        # String or Regexp describing a value expected in the flash.  Will match against any flash key.
        #
        # Example:
        #   resource.create.flash = /created/
        attr_accessor :flash

        # Actions that should be denied (only used by resource.denied).  <i>Note that these actions will
        # only be tested if they are also listed in +resource.actions+</i>
        # The special value of :all will deny all of the REST actions.
        attr_accessor :actions
      end

      # Name of key in params that references the primary key.
      # Will almost always be :id (default), unless you are using a plugin or have patched rails.
      attr_accessor :identifier

      # Name of the ActiveRecord class this resource is responsible for.  Automatically determined from
      # test class if not explicitly set.  UserTest => "User"
      attr_accessor :klass

      # Name of the instantiated ActiveRecord object that should be used by some of the tests.
      # Defaults to the underscored name of the AR class.  CompanyManager => :company_manager
      attr_accessor :object

      # Name of the parent AR objects.  Can be set as parent= or parents=, and can take either
      # the name of the parent resource (if there's only one), or an array of names (if there's
      # more than one).
      #
      # Example:
      #   # in the routes...
      #   map.resources :companies do
      #     map.resources :people do
      #       map.resources :limbs
      #     end
      #   end
      #
      #   # in the tests...
      #   class PeopleControllerTest < Test::Unit::TestCase
      #     should_be_restful do |resource|
      #       resource.parent = :companies
      #     end
      #   end
      #
      #   class LimbsControllerTest < Test::Unit::TestCase
      #     should_be_restful do |resource|
      #       resource.parents = [:companies, :people]
      #     end
      #   end
      attr_accessor :parent
      alias parents parent
      alias parents= parent=

      # Actions that should be tested.  Must be a subset of VALID_ACTIONS (default).
      # Tests for each actionw will only be generated if the action is listed here.
      # The special value of :all will test all of the REST actions.
      #
      # Example (for a read-only controller):
      #   resource.actions = [:show, :index]
      attr_accessor :actions

      # Formats that should be tested.  Must be a subset of VALID_FORMATS (default).
      # Each action will be tested against the formats listed here.  The special value
      # of :all will test all of the supported formats.
      #
      # Example:
      #   resource.actions = [:html, :xml]
      attr_accessor :formats

      # ActionOptions object specifying options for the create action.
      attr_accessor :create

      # ActionOptions object specifying options for the update action.
      attr_accessor :update

      # ActionOptions object specifying options for the desrtoy action.
      attr_accessor :destroy

      # DeniedOptions object specifying which actions should return deny a request, and what should happen in that case.
      attr_accessor :denied

      def initialize # :nodoc:
        @create  = ActionOptions.new
        @update  = ActionOptions.new
        @destroy = ActionOptions.new
        @denied  = DeniedOptions.new

        @create.flash  ||= /created/i
        @update.flash  ||= /updated/i
        @destroy.flash ||= /removed/i
        @denied.flash  ||= /denied/i

        @create.params  ||= {}
        @update.params  ||= {}

        @actions = VALID_ACTIONS
        @formats = VALID_FORMATS
        @denied.actions = []
      end

      def normalize!(target) # :nodoc:
        @denied.actions  = VALID_ACTIONS if @denied.actions == :all
        @actions         = VALID_ACTIONS if @actions        == :all
        @formats         = VALID_FORMATS if @formats        == :all

        @denied.actions  = @denied.actions.map(&:to_sym)
        @actions         = @actions.map(&:to_sym)
        @formats         = @formats.map(&:to_sym)

        ensure_valid_members(@actions,        VALID_ACTIONS, 'actions')
        ensure_valid_members(@denied.actions, VALID_ACTIONS, 'denied.actions')
        ensure_valid_members(@formats,        VALID_FORMATS, 'formats')

        @identifier    ||= :id
        @klass         ||= target.name.gsub(/ControllerTest$/, '').singularize.constantize
        @object        ||= @klass.name.tableize.singularize
        @parent        ||= []
        @parent          = [@parent] unless @parent.is_a? Array

        collection_helper = [@parent, @object.to_s.pluralize, 'url'].flatten.join('_')
        collection_args   = @parent.map {|n| "@#{object}.#{n}"}.join(', ')
        @destroy.redirect ||= "#{collection_helper}(#{collection_args})"

        member_helper = [@parent, @object, 'url'].flatten.join('_')
        member_args   = [@parent.map {|n| "@#{object}.#{n}"}, "@#{object}"].flatten.join(', ')
        @create.redirect  ||= "#{member_helper}(#{member_args})"
        @update.redirect  ||= "#{member_helper}(#{member_args})"
        @denied.redirect  ||= "new_session_url"
      end

      private

      def ensure_valid_members(ary, valid_members, name)  # :nodoc:
        invalid = ary - valid_members
        raise ArgumentError, "Unsupported #{name}: #{invalid.inspect}" unless invalid.empty?
      end
    end
  end
end

Shoulda::Controller::ResourceOptions::VALID_FORMATS.each do |format|
  include "Shoulda::Controller::#{format.to_s.upcase}".constantize
end

def should_be_restful(&blk) # :yields: resource
   resource = Shoulda::Controller::ResourceOptions.new
   blk.call(resource)
   resource.normalize!(self.is_a?(Class) ? self : self.parent)

   resource.formats.each do |format|
     resource.actions.each do |action|
       if self.respond_to? :"make_#{action}_#{format}_tests"
         self.send(:"make_#{action}_#{format}_tests", resource)
       else
         should "test #{action} #{format}" do
           flunk "Test for #{action} as #{format} not implemented"
         end
       end
     end
   end
 end

 def should_render_a_form

   should "display a form" do
     assert_select "form", true, "The template doesn't contain a <form> element"
   end
 end

 def get_existing_record(res) # :nodoc:
   returning(instance_variable_get("@#{res.object}")) do |record|
     assert(record, "This test requires you to set @#{res.object} in your setup block")
   end
 end

 def make_parent_params(resource, record = nil, parent_names = nil) # :nodoc:
   parent_names ||= resource.parents.reverse
   return {} if parent_names == [] # Base case
   parent_name = parent_names.shift
   parent = record ? record.send(parent_name) : parent_name.to_s.classify.constantize.find(:first)

   { :"#{parent_name}_id" => parent.to_param }.merge(make_parent_params(resource, parent, parent_names))
 end
