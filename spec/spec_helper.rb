require 'rubygems'
require 'merb-core'
require 'spec'
require 'data_mapper'
require 'can_has_fixtures'

# Add the dependency in a before_app_loads hook
Merb::BootLoader.before_app_loads { require(File.join(File.dirname(__FILE__), '..', 'lib', 'merb-E-mart')) }

DataMapper.setup(:default, 'sqlite3::memory:')

class User
  include DataMapper::Resource
  
  attr_accessor :password, :password_confirmation

  property :id, Integer, :serial => true
  property :email, String, :length => 3..100, :nullable => false, :unique => true
  property :crypted_password, String
  property :salt, String
  property :activation_code, String
  property :activated_at, DateTime
  property :remember_token_expires_at, DateTime
  property :remember_token, String
  property :password_reset_code, String
  property :created_at, DateTime
  property :updated_at, DateTime
  property :type,           Class    # single-table inheritance
end

# Using Merb.root below makes sure that the correct root is set for
# - testing standalone, without being installed as a gem and no host application
# - testing from within the host application; its root will be used
Merb.start_environment(
  :testing => true, 
  :adapter => 'runner', 
  :environment => ENV['MERB_ENV'] || 'test',
  :merb_root => Merb.root
)

module Merb
  module Test
    module SliceHelper
      
      # The absolute path to the current slice
      def current_slice_root
        @current_slice_root ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
      end
      
      # Whether the specs are being run from a host application or standalone
      def standalone?
        not $SLICED_APP
      end
      
    end
  end
end

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Merb::Test::SliceHelper)
end

module MerbEMart
  Address.fixture {{
    :first_name   => Random.word(:max => 50),
    :last_name    => Random.word(:max => 50),
    :address1     => Random.address,
    :postal_code  => "%05d" % rand(100_000) + "-%04d" % rand([0, 1_000].random),
    :company      => (1..4).random.of {Random.word(:max => 25)}.join(' '),
    :telephone    => Random.phone_number,
    :address2     => Random.address,
    :city         => Random.word(:max => 50),
    :country      => country = Country.gen,
    :state        => State.gen(:country => country)
  }}

  Country.fixture {{
    :code => Random.country_code,
    :name => Random.word(:max => 100, :unique => true)
  }}

  State.fixture {{
    :country  => Country.gen,
    :name     => name = Random.word,
    :abbr     => name[0, 10]
  }}
end

class Random
  def country_code(options = {:used => true, :unique => true})
    code = 2.of {('a'..'z').random}.to_s until satisfies?(code, options)
    
    @@used << code if options[:used]
    code
  end
  
  def address
    "#{rand(100_000)} #{word(:max => 75)} #{%w[st rd ln ave pkwy].random}"
  end

  def phone_number
    "#{(100..999).random}-#{(100..999).random}-#{(0..9999).random}"
  end
end