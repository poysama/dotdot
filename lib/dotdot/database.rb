module Dotdot
  class Database
    attr_reader :root, :options

    def initialize(options)
      @logger       = Logger.new(STDOUT)
      @options      = { 'path'    => Dir.pwd,
                        'group'   => nil,
                        'verbose' => false }.merge(options)

      @sql_options  = { :logger => @logger, :sql_log_level => :info }
      @prefix_stack = []
    end

    def setup
      @sql_options[:logger].level = @options['verbose'] ? Logger::DEBUG : Logger::WARN

      @root    = @options['path']
      @file    = File.join(root, FILE_DIR ,"#{@options['target']}#{FILE_EXTENSION}")
      @db      = Sequel.sqlite(@file, @sql_options)
      @dataset = @db[:dotdot]

      create_table_if_needed
    end

    def update(key, value, group = nil)
      group ||= @group
      key = final_key(key)

      @dataset.filter(:key => key, :group => group).update(:value => value)

      stack_pop
    end

    def group(group = nil, &block)
      @group ||= group

      @db.transaction do
        yield
      end
    end

    def globals(&block)
      @group = "globals"

      @db.transaction do
        yield
      end
    end

    def prefix(prefix, &block)
      @prefix_stack.push(prefix)
      yield

      stack_pop
    end

    def has_key?(key, group)
      group ||= group.to_s

      val = @dataset.where(:key => key, :group => group).count

      if val == 0
        val = @dataset.where(:key => key, :group => "globals").count

        val == 0 ? false : true
      else
        true
      end
    end

    def get(key, group = nil)
      group ||= group.to_s

      val = @dataset.where(:key => key, :group => group)

      if val.empty?
        val = @dataset.where(:key => key, :group => "globals")
      end

      if val.count > 0
        val.first[:value]
      else
        raise "key \'#{key}\' cannot be found!"
      end
    end

    def get_if_key_exists(key, group = nil)
      group ||= group.to_s

      get(key, group) if has_key?(key, group)
    end

    def get_children(key, group = nil)
      group ||= group.to_s
      values = []

      res = @dataset.where(:key.like("#{key}%"), :group => group)

      if res.empty?
        res = @dataset.where(:key.like("#{key}%"), :group => "globals")
      end

      key = key.split('.')

      res.each do |r|
        res_key = r[:key].split('.')
        res_key = (res_key - key).shift
        values.push(res_key)
      end

      if values.count > 0
        values & values
      else
        raise "no values for \'#{key}\'!"
      end
    end

    def set(key, value, group = nil)
      group ||= @group
      key = final_key(key)

      @dataset.insert(:key => key, :value => value, :group => group)

      stack_pop
    end

    def delete_key(key, group = nil)
      group ||= @group

      key = final_key(key)

      @dataset.filter(:key => key, :group => group).delete
      stack_pop
    end

    protected

    def migrate
      init_file = File.join(@options['path'], INIT_FILE)
      require init_file if File.exist?(init_file)

      Migration.new(self).start
    end

    private

    def final_key(key)
      unless @prefix_stack.empty?
        @prefix_stack.push(key)
        key = nil
      end

      key ||= @prefix_stack.join('.')
    end

    def stack_pop
      @prefix_stack.pop
    end

    def create_table_if_needed
      if @db.tables.include? :dotdot
        @db.drop_table :dotdot
      end

      @db.create_table :dotdot do
        String :key
        String :value
        String :group
      end
    end
  end
end
