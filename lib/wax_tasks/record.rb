# frozen_string_literal: true

module WaxTasks
  #
  class Record
    attr_reader :pid, :hash, :order

    def initialize(hash)
      @hash  = hash.compact
      @pid   = @hash.dig 'pid'
      @order = @hash.dig 'order'
    end

    #
    #
    def lunr_normalize_values
      @hash.transform_values! { |v| Utils.lunr_normalize v }
    end

    #
    #
    def split_lists
      @hash.transform_values! do |v|
        next v unless v.include? '|'
        v.split('|').map(&:strip)
      end
    end

    #
    #
    def keys
      @hash.keys
    end

    # PATCH :: rename 'fullwidth' to 'full' to
    # (1) avoid breaking wax_iiif with special 'full' variant label
    # (2) avoid breaking wax_theme which still expects 'full' to provide an image path
    # this can be deprecated when a new version of wax_theme looks for another fullsize key
    #
    def set(key, value)
      key = 'full' if key == 'fullwidth'
      @hash[key] = value
    end

    #
    #
    def permalink?
      @hash.key? 'permalink'
    end

    #
    #
    def order?
      @order.is_a? String
    end

    #
    #
    def keep_only(fields)
      @hash.select! { |k, _v| fields.include? k }
    end

    #
    #
    def write_to_page(dir)
      raise Error::MissingPid if @pid.nil?

      path = "#{dir}/#{Utils.slug(@pid)}.md"
      if File.exist? path
        0
      else
        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') { |f| f.puts "#{@hash.to_yaml}---" }
        1
      end
    end
  end
end
