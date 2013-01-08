require 'sqlite3'
require 'sequel'

module Dotdot
  autoload :Base,      'dotdot/base'
  autoload :Helpers,   'dotdot/helpers'
  autoload :Migration, 'dotdot/migration'
  autoload :Version,   'dotdot/version'
end
