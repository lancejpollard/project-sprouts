
module Sprout # :nodoc:
  
  # The MXMLCDebug helper wraps up the flashplayer and mxmlc tasks by
  # using either a Singleton or provided ProjectModel instance.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   debug :debug
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   debug :debug => :model
  #
  # Configuring the proxied Sprout::MXMLCTask
  #   debug :debug do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCDebug < MXMLCHelper
  
    def initialize(args, &block)
      super

      outer_task = define_outer_task

      mxmlc "#{task_name}:#{output}" do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        yield t if block_given?
        define_player t
      end
      
      outer_task.prerequisites << output
      outer_task.prerequisites << player_task_name
    end
    
  end
end

def debug(args, &block)
    return Sprout::MXMLCDebug.new(args, &block)
end
