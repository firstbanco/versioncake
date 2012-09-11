require 'active_support/core_ext/module/attribute_accessors.rb'

module ActionView
  class Template
    module Versions

      VERSION_STRING = "api_version"

      mattr_accessor :supported_version_numbers
      self.supported_version_numbers = []

      mattr_accessor :extraction_strategy
      self.extraction_strategy = :all

      def self.extract_version(request)
        if request.query_parameters.has_key? VERSION_STRING.to_sym
          request.query_parameters[VERSION_STRING.to_sym].to_i
        elsif request.headers.has_key?("HTTP_#{VERSION_STRING.upcase}")
          request.headers["HTTP_#{VERSION_STRING.upcase}"].to_i
        elsif request.headers.has_key?("HTTP_ACCEPT") && match = request.headers["HTTP_ACCEPT"].match(%{#{VERSION_STRING}=([0-9])})
          match[1].to_i
        end
      end

      def self.supported_version_numbers=(val)
        case val
          when Range
          @@supported_version_numbers = val.to_a
        when Array
          @@supported_version_numbers = val
        else
          @@supported_version_numbers = Array.wrap(val)
        end
        @@supported_version_numbers.reverse!
      end

      def self.supported_versions(requested_version_number=nil)
        self.supported_version_numbers.collect do |supported_version_number|
          if requested_version_number.nil? || supported_version_number <= requested_version_number
            :"v#{supported_version_number}"
          end
        end
      end

      def self.supports_version?(version)
        self.supported_version_numbers.include? version
      end

      def self.latest_version
        self.supported_version_numbers.first
      end

    end
  end
end