require "interceptors/version"

require "interceptors/ds/node"
require "interceptors/ds/stack"
require "interceptors/middleware"
require "interceptors/executor"
require "interceptors/base"
require "interceptors/context"

module Interceptors
  def self.root
    Pathname.new(File.expand_path('../..', __FILE__))
  end
end
