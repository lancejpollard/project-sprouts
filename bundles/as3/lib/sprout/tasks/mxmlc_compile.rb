
module Sprout # :nodoc:
  
  # The MXMLCCompile task compiles a Flex project, but doesn't
  # run it in the flash player
  #
  # The simple case that uses a Singleton ProjectModel:
  #   compile :my_compile_task
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   compile :compile => :model
  #
  # Configuring the proxied Sprout::MXMLCTask (the |t|)
  #   compile :compile do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCCompile < MXMLCHelper
  
    def initialize(args, &block)
      super

      outer_task = define_outer_task

      # In order not to confuse the Rake::Application,
      # this mxmlc task is named with a namespace.
      # If it was named with just the output, then multiple tasks
      # using the same output would start being run seemingly randomly
      mxmlc "#{task_name}:#{output}" do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        yield t if block_given?
      end
      
      outer_task.prerequisites << "#{task_name}:#{output}"
    end
    
  end
end

def compile(args, &block)
  return Sprout::MXMLCCompile.new(args, &block)
end