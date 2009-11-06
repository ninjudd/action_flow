class Object

  ## Taken from http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  # The hidden singleton lurks behind everyone
unless defined?(metaclass)
  def metaclass; class << self; self; end; end
end

unless defined?(meta_eval)
  def meta_eval &blk; metaclass.instance_eval &blk; end
end

unless defined?(meta_def)
  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end
end

unless defined?(try)
  def try(method, *args, &block)
    return unless method
    return nil if is_a?(NilClass) and [:id, 'id'].include?(method)
    self.send(method, *args, &block) if respond_to?(method)
  end
end

end # class Object

class Module

unless defined?(inheritable_class_attr)
  def inheritable_class_attr(attribute, &block)
    accessor = "_#{attribute}"
    meta_def attribute do |*args|
      if args.empty?
        try(accessor)
      else
        meta_def accessor do
          block ? block.call(args.first) : args.first
        end
      end
    end
  end
end

end # class Module
