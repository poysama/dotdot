module Dotdot
  class Migration
    include Helpers

    attr_reader :options

    def initialize(database)
      @database = database
      @options  = database.options
      @db_root  = @database.root
    end

    def start
      file_stack = []

      sort_directories.each do |p|
        path = File.join(@db_root, p)

        if p == 'targets'
          if !@options['location'].empty? && @options['location'] != @options['target']
            f = File.join(path, "#{@options['target']}_#{@options['location']}.rb")
          else
            f = File.join(path, "#{@options['target']}.rb")
          end

          if File.exists?(f)
            require f
            file_stack.push(f)
          else
            raise "File #{f} doesn't exist!"
          end
        elsif p == '.'
          if File.exist?(File.join(path, CUSTOM_FILE))
            f = Dir["#{path}/#{CUSTOM_FILE}"].shift
            require f
            file_stack.push(f)
          end
        else
          Dir["#{path}/*.rb"].each do |d|
            require d
            file_stack.push(d)
          end
        end

        file_stack.each do |f|
          class_name = File.basename(f).chomp(".rb")
          camelized_class_name = camelize(class_name)
          klass = Dotdot::Migrations.const_get(camelized_class_name)
          k = klass.new(@database)
          k.migrate!
        end
        file_stack.clear
      end
    end

    def sort_directories
      dir_stack = ["base", "targets", '.']
    end

    protected

    def migrate!
      raise "class #{self.class.name} doesn't have a migrate method. Override!"
    end

    def set(key, value, set = nil)
      @database.set(key, value, set)
    end

    def group(group, &block)
      @database.group(group, &block)
    end

    def globals(&block)
      @database.globals(&block)
    end

    def prefix(prefix, &block)
      @database.prefix(prefix, &block)
    end

    def delete_key(key, group = nil)
      @database.delete_key(key, group)
    end

    def update(key, value)
      @database.update(key, value)
    end
  end
end
