require 'best_in_place'
require 'lazyhash'

module Interpret
  mattr_accessor :backend
  mattr_accessor :logger
  mattr_accessor :sweeper
  mattr_accessor :parent_controller
  mattr_accessor :registered_envs
  mattr_accessor :scope
  mattr_accessor :current_user
  mattr_accessor :layout
  mattr_accessor :soft
  mattr_accessor :live_edit
  mattr_accessor :black_list

  @@controller = "action_controller/base"
  @@registered_envs = [:production, :staging]
  @@scope = ""
  @@layout = "interpret_base"
  @@soft = false
  @@live_edit = false
  @@black_list = []

  def self.configure
    yield self
  end

  def self.fixed_blacklist
    @@black_list.select{|x| !x.include?("*")}
  end

  def self.wild_blacklist
    @@black_list.select{|x| x.include?("*")}.map{|x| x.gsub("*", "")}
  end
end

require 'interpret/engine' if defined? Rails

ActionView::Base.send(:include, Interpret::InterpretHelpers)
