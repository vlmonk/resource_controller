module ResourceController
  ACTIONS           = [:index, :show, :new_action, :create, :edit, :update, :destroy].freeze
  SINGLETON_ACTIONS = (ACTIONS - [:index]).freeze
  FAILABLE_ACTIONS  = ACTIONS - [:index, :new_action, :edit].freeze
  NAME_ACCESSORS    = [:model_name, :route_name, :object_name]

  autoload :Accessors,              'resource_controller/accessors'
  autoload :ActionOptions,          'resource_controller/action_options'
  autoload :Actions,                'resource_controller/actions'
  autoload :Base,                   'resource_controller/base'
  autoload :ClassMethods,           'resource_controller/class_methods'
  autoload :Controller,             'resource_controller/controller'
  autoload :FailableActionOptions,  'resource_controller/failable_action_options'
  autoload :Helpers,                'resource_controller/helpers'
  autoload :ResponseCollector,      'resource_controller/response_collector'
  autoload :Singleton,              'resource_controller/singleton'
  autoload :Urligence,              'urligence'
  class Railtie < Rails::Railtie
  end
end

class ActionController::Base

  def self.resource_controller(*args)
    include ResourceController::Controller
    include ResourceController::Urligence
    extend ResourceController::ClassMethods
    helper_method :smart_url

    if args.include?(:singleton)
      include ResourceController::Helpers::SingletonCustomizations
    end
  end

end


