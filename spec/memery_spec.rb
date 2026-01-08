# frozen_string_literal: true

RSpec.describe Memery do
  def define_base_class(parent_class = Object, &block)
    Class.new(parent_class) do
      include Memery

      def calls
        @calls ||= []
      end

      class_exec(&block) if block
    end
  end

  def define_base_module(&block)
    Module.new do
      include Memery

      class_exec(&block) if block
    end
  end

  let(:test_object) { test_class.new }

  shared_examples 'a correctly memoized object' do
    describe 'values' do
      subject { values }

      it { is_expected.to eq expected_values }
    end

    describe 'calls' do
      subject { test_object.calls }

      before do
        values
      end

      it { is_expected.to eq expected_calls }
    end
  end

  describe 'returning value' do
    subject { test_class.memoize :memoized_method }

    let(:test_class) do
      define_base_class do
        def memoized_method
          calls << __method__
          42
        end

        def another_memoized_method
          calls << __method__
          8
        end
      end
    end

    it { is_expected.to eq :memoized_method }

    context 'with multiple method names' do
      subject { test_class.memoize :memoized_method, :another_memoized_method }

      it { is_expected.to eq %i[memoized_method another_memoized_method] }
    end
  end

  context 'when methods without args' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method
          calls << __method__
          42
        end

        memoize def another_memoized_method
          calls << __method__
          8
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.another_memoized_method,
        test_object.memoized_method,
        test_object.another_memoized_method
      ]
    end

    let(:expected_values) { [42, 8, 42, 8] }
    let(:expected_calls) { %i[memoized_method another_memoized_method] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'with multiple method names' do
    let(:test_class) do
      define_base_class do
        def memoized_method
          calls << __method__
          42
        end

        def another_memoized_method
          calls << __method__
          8
        end

        memoize :memoized_method, :another_memoized_method
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.another_memoized_method,
        test_object.memoized_method,
        test_object.another_memoized_method
      ]
    end

    let(:expected_values) { [42, 8, 42, 8] }
    let(:expected_calls) { %i[memoized_method another_memoized_method] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'without method names' do
    let(:test_class) do
      define_base_class do
        memoize

        def memoized_method
          calls << __method__
          42
        end

        def another_memoized_method
          calls << __method__
          52
        end

        unmemoize

        def non_memoized_method
          calls << __method__
          8
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.another_memoized_method,
        test_object.non_memoized_method,
        test_object.memoized_method,
        test_object.another_memoized_method,
        test_object.non_memoized_method
      ]
    end

    let(:expected_values) { [42, 52, 8, 42, 52, 8] }
    let(:expected_calls) do
      %i[memoized_method another_memoized_method non_memoized_method non_memoized_method]
    end

    it_behaves_like 'a correctly memoized object'
  end

  context 'when double memoized' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method
          calls << __method__
          42
        end

        memoize :memoized_method
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.memoized_method
      ]
    end

    let(:expected_values) { [42, 42] }
    let(:expected_calls) { %i[memoized_method] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'when method with args' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method(first, second)
          calls << [first, second]
          [first, second]
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 2),
        test_object.memoized_method(1, 2)
      ]
    end

    let(:expected_values) { [[1, 1], [1, 1], [1, 2], [1, 2]] }
    let(:expected_calls) { [[1, 1], [1, 2]] }

    it_behaves_like 'a correctly memoized object'

    context 'when receiving Hash-like object' do
      let(:object_class) do
        Struct.new(:first_name, :last_name) do
          # For example, Sequel models have such implicit coercion,
          # which conflicts with `**kwargs`.
          alias_method :to_hash, :to_h
        end
      end

      let(:object) { object_class.new('John', 'Wick') }

      let(:values) do
        [
          test_object.memoized_method(1, object),
          test_object.memoized_method(1, object),
          test_object.memoized_method(1, 2),
          test_object.memoized_method(1, 2)
        ]
      end

      let(:expected_values) { [[1, object], [1, object], [1, 2], [1, 2]] }
      let(:expected_calls) { [[1, object], [1, 2]] }

      it_behaves_like 'a correctly memoized object'
    end
  end

  context 'when method with keyword args' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method(first, second:)
          calls << [first, second]
          [first, second]
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method(1, second: 2),
        test_object.memoized_method(1, second: 2),
        test_object.memoized_method(1, second: 3),
        test_object.memoized_method(1, second: 3)
      ]
    end

    let(:expected_values) { [[1, 2], [1, 2], [1, 3], [1, 3]] }
    let(:expected_calls) { [[1, 2], [1, 3]] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'when method with splat argument' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method(*args)
          calls << args
          args
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 2),
        test_object.memoized_method(1, 2)
      ]
    end

    let(:expected_values) { [[1, 1], [1, 1], [1, 2], [1, 2]] }
    let(:expected_calls) { [[1, 1], [1, 2]] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'when method with double splat argument' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method(first, **kwargs)
          calls << [first, kwargs]
          [first, kwargs]
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method(1, second: 2),
        test_object.memoized_method(1, second: 2),
        test_object.memoized_method(1, second: 3),
        test_object.memoized_method(1, second: 3)
      ]
    end

    let(:expected_values) do
      [[1, { second: 2 }], [1, { second: 2 }], [1, { second: 3 }], [1, { second: 3 }]]
    end

    let(:expected_calls) do
      [[1, { second: 2 }], [1, { second: 3 }]]
    end

    it_behaves_like 'a correctly memoized object'
  end

  context 'when calling method with a block' do
    let(:test_class) do
      define_base_class do
        memoize def memoized_method
          calls << __method__
          block_given? ? yield : 42
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.memoized_method,
        test_object.memoized_method { 84 },
        test_object.memoized_method
      ]
    end

    let(:expected_values) { [42, 42, 84, 42] }
    let(:expected_calls) { %i[memoized_method memoized_method] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'when calling private method' do
    let(:test_class) do
      define_base_class do
        private

        memoize def memoized_method; end
      end
    end

    it { expect { test_object.memoized_method }.to raise_error(NoMethodError, /private method/) }
  end

  context 'when calling protected method' do
    let(:test_class) do
      define_base_class do
        protected

        memoize def memoized_method; end
      end
    end

    it { expect { test_object.memoized_method }.to raise_error(NoMethodError, /protected method/) }
  end

  describe 'chaining macros' do
    subject { test_class.macro_received }

    let(:test_class) do
      define_base_class do
        class << self
          def macro_received
            @macro_received ||= []
          end

          def macro(name)
            macro_received << name
          end
        end

        macro memoize def memoized_method; end
      end
    end

    it { is_expected.to eq %i[memoized_method] }
  end

  context 'when class is inherited' do
    let(:parent_class) do
      define_base_class do
        def parent_calls
          @parent_calls ||= []
        end

        memoize def memoized_method(first, second)
          parent_calls << [first, second]
          [first, second]
        end
      end
    end

    let(:test_class) do
      define_base_class(parent_class) do
        memoize def memoized_method(first, second)
          calls << [first, second]
          super(first * 2, second * 2)
          :result_from_child_class
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 2),
        test_object.memoized_method(1, 2)
      ]
    end

    let(:expected_values) do
      %i[
        result_from_child_class
        result_from_child_class
        result_from_child_class
        result_from_child_class
      ]
    end

    let(:expected_calls) { [[1, 1], [1, 2]] }

    it_behaves_like 'a correctly memoized object'

    describe 'parent calls' do
      subject { test_object.parent_calls }

      before do
        values
      end

      it { is_expected.to eq [[2, 2], [2, 4]] }
    end
  end

  context 'when memoization from included module' do
    let(:including_module) do
      Module.new do
        include Memery

        memoize def memoized_method
          calls << __method__
          42
        end
      end
    end

    let(:test_class) do
      including_module = self.including_module

      define_base_class do
        include including_module
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.memoized_method,
        test_object.memoized_method
      ]
    end

    let(:expected_values) { [42, 42, 42] }
    let(:expected_calls) { %i[memoized_method] }

    it_behaves_like 'a correctly memoized object'

    context 'when memoization in class' do
      let(:test_class) do
        including_module = self.including_module

        define_base_class do
          include including_module

          memoize def memoized_method_from_class
            calls << __method__
            8
          end
        end
      end

      let(:values) do
        [
          test_object.memoized_method_from_class,
          test_object.memoized_method_from_class,
          test_object.memoized_method_from_class
        ]
      end

      let(:expected_values) { [8, 8, 8] }
      let(:expected_calls) { %i[memoized_method_from_class] }

      it_behaves_like 'a correctly memoized object'
    end
  end

  context 'when module extended via `ActiveSupport::Concern`' do
    let(:including_module) do
      Module.new do
        extend ActiveSupport::Concern
        include Memery

        included do
          attr_accessor :as_accessor
        end
      end
    end

    let(:test_class) do
      including_module = self.including_module

      define_base_class do
        include including_module
      end
    end

    describe 'executes `included` block' do
      subject { test_object.as_accessor }

      before do
        test_object.as_accessor = 15
      end

      it { is_expected.to eq 15 }
    end
  end

  context 'with class method with args' do
    let(:test_object) do
      Class.new do
        class << self
          include Memery

          def calls
            @calls ||= []
          end

          memoize def memoized_method(first, second)
            calls << [first, second]
            [first, second]
          end
        end
      end
    end

    let(:values) do
      [
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 2),
        test_object.memoized_method(1, 2)
      ]
    end

    let(:expected_values) { [[1, 1], [1, 1], [1, 2], [1, 2]] }
    let(:expected_calls) { [[1, 1], [1, 2]] }

    it_behaves_like 'a correctly memoized object'
  end

  context 'when method does not exist' do
    let(:test_class) do
      define_base_class do
        memoize :foo
      end
    end

    it { expect { test_class }.to raise_error(ArgumentError, /Method foo is not defined/) }
  end

  context 'when method is forwarded' do
    let(:inner_class) do
      define_base_class do
        memoize def memoized_method
          calls << __method__
          42
        end
      end
    end

    let(:test_class) do
      inner_class = self.inner_class

      define_base_class do
        remove_method :calls

        extend Forwardable

        def_delegators :inner_object, :memoized_method, :calls

        define_method :inner_object do
          inner_class.new
        end
        memoize :inner_object
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.memoized_method,
        test_object.memoized_method
      ]
    end

    let(:expected_values) { [42, 42, 42] }
    let(:expected_calls) { %i[memoized_method] }

    it_behaves_like 'a correctly memoized object'
  end

  describe ':condition option' do
    before do
      test_object.environment = environment
    end

    let(:test_class) do
      define_base_class do
        attr_accessor :environment

        memoize def memoized_method
          calls << __method__
          42
        end

        def another_memoized_method
          calls << __method__
          8
        end

        memoize :another_memoized_method, condition: -> { environment == 'production' }
      end
    end

    let(:values) do
      [
        test_object.memoized_method,
        test_object.another_memoized_method,
        test_object.memoized_method,
        test_object.another_memoized_method
      ]
    end

    context 'when returns true' do
      let(:environment) { 'production' }

      let(:values) do
        [
          test_object.memoized_method,
          test_object.another_memoized_method,
          test_object.memoized_method,
          test_object.another_memoized_method
        ]
      end

      let(:expected_values) { [42, 8, 42, 8] }
      let(:expected_calls) { %i[memoized_method another_memoized_method] }

      it_behaves_like 'a correctly memoized object'
    end

    context 'when returns false' do
      let(:environment) { 'development' }

      let(:expected_values) { [42, 8, 42, 8] }
      let(:expected_calls) { %i[memoized_method another_memoized_method another_memoized_method] }

      it_behaves_like 'a correctly memoized object'
    end

    context 'with multiple methods in single call' do
      let(:test_class) do
        define_base_class do
          attr_accessor :environment

          def memoized_method
            calls << __method__
            42
          end

          def another_memoized_method
            calls << __method__
            8
          end

          memoize :memoized_method, :another_memoized_method,
            condition: -> { environment == 'production' }
        end
      end

      context 'when returns true' do
        let(:environment) { 'production' }

        let(:values) do
          [
            test_object.memoized_method,
            test_object.another_memoized_method,
            test_object.memoized_method,
            test_object.another_memoized_method
          ]
        end

        let(:expected_values) { [42, 8, 42, 8] }
        let(:expected_calls) { %i[memoized_method another_memoized_method] }

        it_behaves_like 'a correctly memoized object'
      end

      context 'when returns false' do
        let(:environment) { 'development' }

        let(:expected_values) { [42, 8, 42, 8] }
        let(:expected_calls) do
          %i[memoized_method another_memoized_method memoized_method another_memoized_method]
        end

        it_behaves_like 'a correctly memoized object'
      end
    end
  end

  describe ':ttl option' do
    def make_calls
      [
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 1),
        test_object.memoized_method(1, 2),
        test_object.memoized_method(1, 2)
      ]
    end

    let(:test_class) do
      define_base_class do
        def memoized_method(first, second)
          calls << [first, second]
          [first, second]
        end

        memoize :memoized_method, ttl: 3
      end
    end

    let(:values) { make_calls }

    let(:expected_values) { [[1, 1], [1, 1], [1, 2], [1, 2]] }
    let(:expected_calls) { [[1, 1], [1, 2]] }

    it_behaves_like 'a correctly memoized object'

    context 'when ttl has expired' do
      before do
        make_calls

        allow(Process).to(
          receive(:clock_gettime).with(Process::CLOCK_MONOTONIC)
            .and_wrap_original { |m, *args| m.call(*args) + 5 }
        )

        make_calls
      end

      let(:expected_calls) { [[1, 1], [1, 2], [1, 1], [1, 2]] }

      it_behaves_like 'a correctly memoized object'
    end
  end

  describe 'flushing cache' do
    context 'without arguments' do
      let(:test_class) do
        define_base_class do
          memoize def memoized_method
            calls << __method__
            42
          end
        end
      end

      context 'without cache' do
        let(:values) do
          test_object.clear_memery_cache!
          [test_object.memoized_method, test_object.memoized_method]
        end

        let(:expected_values) { [42, 42] }
        let(:expected_calls) { %i[memoized_method] }

        it_behaves_like 'a correctly memoized object'
      end

      context 'with cache' do
        let(:values) do
          result = [test_object.memoized_method, test_object.memoized_method]
          test_object.clear_memery_cache!
          result.push test_object.memoized_method, test_object.memoized_method
        end

        let(:expected_values) { [42, 42, 42, 42] }
        let(:expected_calls) { %i[memoized_method memoized_method] }

        it_behaves_like 'a correctly memoized object'
      end
    end

    context 'with specific methods as arguments' do
      let(:test_class) do
        define_base_class do
          memoize def memoized_method
            calls << __method__
            42
          end

          memoize def another_memoized_method(first, second)
            calls << [first, second]
            [first, second]
          end

          memoize def yet_another_memoized_method(first, second)
            calls << [first, second]
            [first, second]
          end
        end
      end

      context 'without cache' do
        let(:values) do
          test_object.clear_memery_cache! :memoized_method, :yet_another_memoized_method

          make_calls
        end

        let(:expected_values) do
          [
            42, 42, [1, 2], [1, 2], [3, 4], [3, 4], [5, 6], [5, 6], [7, 8], [7, 8]
          ]
        end

        let(:expected_calls) do
          [
            :memoized_method,
            [1, 2],
            [3, 4],
            [5, 6],
            [7, 8]
          ]
        end

        def make_calls
          [
            test_object.memoized_method,
            test_object.memoized_method,
            test_object.another_memoized_method(1, 2),
            test_object.another_memoized_method(1, 2),
            test_object.another_memoized_method(3, 4),
            test_object.another_memoized_method(3, 4),
            test_object.yet_another_memoized_method(5, 6),
            test_object.yet_another_memoized_method(5, 6),
            test_object.yet_another_memoized_method(7, 8),
            test_object.yet_another_memoized_method(7, 8)
          ]
        end

        it_behaves_like 'a correctly memoized object'
      end

      context 'with cache' do
        let(:values) do
          result = make_calls

          test_object.clear_memery_cache! :memoized_method, :yet_another_memoized_method

          result.concat make_calls
        end

        let(:expected_values) do
          [
            42, 42, [1, 2], [1, 2], [3, 4], [3, 4], [5, 6], [5, 6], [7, 8], [7, 8],
            42, 42, [1, 2], [1, 2], [3, 4], [3, 4], [5, 6], [5, 6], [7, 8], [7, 8]
          ]
        end

        let(:expected_calls) do
          [
            :memoized_method,
            [1, 2],
            [3, 4],
            [5, 6],
            [7, 8],
            :memoized_method,
            [5, 6],
            [7, 8]
          ]
        end

        def make_calls
          [
            test_object.memoized_method,
            test_object.memoized_method,
            test_object.another_memoized_method(1, 2),
            test_object.another_memoized_method(1, 2),
            test_object.another_memoized_method(3, 4),
            test_object.another_memoized_method(3, 4),
            test_object.yet_another_memoized_method(5, 6),
            test_object.yet_another_memoized_method(5, 6),
            test_object.yet_another_memoized_method(7, 8),
            test_object.yet_another_memoized_method(7, 8)
          ]
        end

        it_behaves_like 'a correctly memoized object'
      end
    end
  end

  describe '.memoized?' do
    subject { test_class.memoized?(method_name) }

    context 'when class without memoized methods' do
      let(:test_class) do
        define_base_class
      end

      let(:method_name) { :memoized_method }

      it { is_expected.to be false }
    end

    shared_examples 'a memoizable entity' do
      context 'with public memoized method' do
        let(:test_class) do
          send define_entity_method_name do
            memoize def memoized_method; end
          end
        end

        let(:method_name) { :memoized_method }

        it { is_expected.to be true }
      end

      context 'with private memoized method' do
        let(:test_class) do
          send define_entity_method_name do
            private

            memoize def memoized_method; end
          end
        end

        let(:method_name) { :memoized_method }

        it { is_expected.to be true }
      end

      context 'with non-memoized method' do
        let(:test_class) do
          send define_entity_method_name do
            def non_memoized_method; end
          end
        end

        let(:method_name) { :non_memoized_method }

        it { is_expected.to be false }
      end

      context 'with standard class method' do
        let(:test_class) do
          send define_entity_method_name
        end

        let(:method_name) { :constants }

        it { is_expected.to be false }
      end

      context 'with standard instance method' do
        let(:test_class) do
          send define_entity_method_name
        end

        let(:method_name) { :to_s }

        it { is_expected.to be false }
      end
    end

    context 'with class' do
      let(:define_entity_method_name) { :define_base_class }

      it_behaves_like 'a memoizable entity'
    end

    context 'with module' do
      let(:define_entity_method_name) { :define_base_module }

      it_behaves_like 'a memoizable entity'
    end
  end
end
