
module Sprout # :nodoc:
  class MXMLCHelper # :nodoc:
    attr_reader :model
    
    attr_accessor :use_fcsh
    
    def initialize(args, &block)
      resolve_task_args(args)
      @model = get_model args
    end
    
    def output
      return @output ||= create_output
    end
    
    def input
      return @input ||= create_input
    end

    def task_name
      return @task_name
    end
    
    def prerequisites
      return @prerequisites ||= []
    end
    
    protected
    
    def resolve_task_args(args)
      if(args.is_a?(Symbol))
        @task_name = args.to_s
      elsif(args.is_a?(Hash))
        args.each do |key, value|
          @task_name = key.to_s
          if(value.is_a?(Array))
            value.each do |dep|
              self.prerequisites << dep
            end
          elsif(!value.nil?)
            self.prerequisites << value
          end
        end
      end
    end
    
    def configure_asdoc(compiler)
      compiler.doc_sources << model.src_dir
      model.source_path.each do |path|
        compiler.doc_sources << path
      end
    end
    
    def configure_mxmlc(compiler, is_asdoc=false)
      if(!is_asdoc)
        compiler.input       = input
        compiler.use_fcsh    = use_fcsh || model.use_fcsh
      end

      compiler.gem_name          = model.compiler_gem_name
      compiler.gem_version       = model.compiler_gem_version
      compiler.preprocessor      = model.preprocessor if !model.preprocessor.nil? && compiler.preprocessor.nil?
      compiler.preprocessed_path = model.preprocessed_path if !model.preprocessed_path.nil?

      # Set up library deps
      model.libraries.each do |lib|
        begin
          t = Rake::application[lib]
        rescue StandardError => e
          library lib
        end
        compiler.prerequisites << lib
      end

      compiler.source_path << model.src_dir
      compiler.source_path << model.asset_dir if File.exists?(model.asset_dir)

      model.source_path.each do |path|
        compiler.source_path << path
      end

      model.library_path.each do |path|
        compiler.library_path << path
      end

    end
    
    def configure_mxmlc_application(compiler)
      compiler.warnings                 = true
      compiler.verbose_stacktraces      = true
      compiler.default_background_color = model.background_color if model.background_color
      compiler.default_frame_rate       = model.frame_rate if model.frame_rate
      if(model.width && model.height)
        compiler.default_size           = "#{model.width} #{model.height}"
      end
    end
    
    def define_player(compiler = nil)
      if model.use_fdb
        define_fdb
      else
        flashplayer player_task_name do |t|
          t.swf = output_file
          if !(compiler.nil? and !compiler.trace_output.nil?)
            t.trace_output = compiler.trace_output
          end
        end
      end
    end
    
    def define_fdb
      fdb player_task_name do |t|
        t.file = output_file
        t.kill_on_fault = true
        t.run
        t.continue
        yield t if block_given?
      end
    end
    
    def define_outer_task
      t = task task_name
      self.prerequisites.each do |dep|
        t.prerequisites << dep
      end
      return t
    end
    
    def append_prerequisite(task_name, prerequisite_name)
      t = Rake::application[task_name]
      t.prerequisites << prerequisite_name
    end
    
    def output_file
      @output_file ||= create_output
    end
    
    def create_output_base
      return File.join(@model.bin_dir, @model.project_name)
    end
    
    def create_output
      return "#{create_output_base}-debug.swf"
    end
    
    def player_task_name
      return "run_#{output_file}"
    end
  
    def create_input
      return File.join(@model.src_dir, @model.project_name) + input_extension
    end

    # Provided task name represents a Rake task
    # that has had a ProjectModel appended to it
    def project_model?(name)
      return Rake::application[name].respond_to?('project_model')
    end
    
    def get_model(args)
      # Look for the special, appended task method 'project_model'
      # in the forwarded prerequisites
      if args.is_a?(Symbol)
        return ProjectModel.instance
      end
      
      args.each_value do |deps|
        if(deps.is_a?(Array))
          deps.each do |dep|
            if(project_model?(dep))
              return Rake::application[dep].project_model
            end
          end
        else
          if(project_model?(deps))
            return Rake::application[deps].project_model
          end
        end
      end
      return ProjectModel.instance
    end
    
    def input_extension
      return '.as' unless (@model.language == 'mxml')
      return '.mxml'
    end

  end
end
