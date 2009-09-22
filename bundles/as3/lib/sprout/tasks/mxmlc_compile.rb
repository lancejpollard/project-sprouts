
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
  class MXMLCCompile < MXMLCHelper
  
    def initialize(args, &block)
      super

      outer_task = define_outer_task

      mxmlc "#{task_name}:#{output}" do |t|
        configure_mxmlc t
        yield t if block_given?
      end
      
      outer_task.prerequisites << output
    end
    
  end
end

def compile(args, &block)
    return Sprout::MXMLCDebug.new(args, &block)
end
