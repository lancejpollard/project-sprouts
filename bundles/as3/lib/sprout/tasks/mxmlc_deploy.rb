
module Sprout # :nodoc:

  # The MXMLCDeploy helper wraps up an mxmlc task by
  # using either a Singleton or provided ProjectModel instance.
  #
  # This helper turns off debugging and turns on optimization for
  # the compiled SWF file.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   deploy :deploy
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   deploy :deploy => :model
  #
  # Configuring the proxy Sprout::MXMLCTask
  #   deploy :deploy do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCDeploy < MXMLCHelper

    def initialize(args, &block)
      super
      t = define_outer_task
      t.prerequisites << player_task_name
      
      out_task = mxmlc "#{task_name}:#{output}" do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        t.debug               = false
        t.optimize            = true
        t.warnings            = false
        t.verbose_stacktraces = false
        
        yield t if block_given?
      end
      
      task player_task_name => output
      return out_task
    end

    def create_input
      return File.join(@model.src_dir, @model.project_name) + input_extension
    end
    
    def create_output
      return "#{create_output_base}.swf"
    end
  
  end
end

def deploy(args, &block)
  return Sprout::MXMLCDeploy.new(args, &block)
end
