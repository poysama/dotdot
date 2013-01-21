require 'sqlite3'
require 'sequel'

module Dotdot
  FILE_EXTENSION = '.sqlite'
  FILE_DIR       = 'db'
  INIT_FILE      = 'init.rb'
  CUSTOM_FILE    = 'custom.rb'
  TABLE_NAME     = :dotdot

  autoload :Database,  'dotdot/database'
  autoload :Helpers,   'dotdot/helpers'
  autoload :Migration, 'dotdot/migration'
  autoload :Version,   'dotdot/version'
end
