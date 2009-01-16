module ActiveRecord
  class Base
    class << self
      def set_accessible_association_destroy_flag(flag)
        self.accessible_association_destroy_flag = flag.to_sym
      end
    end

    class_inheritable_accessor :accessible_association_destroy_flag
    self.accessible_association_destroy_flag = :destroy

    attr_accessor accessible_association_destroy_flag

    def destroyable?
      @destroyable ||= !!send(accessible_association_destroy_flag)
    end
  end
end
