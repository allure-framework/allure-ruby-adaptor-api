# frozen_string_literal: true

module Allure
  class AllureLifecycle
    # Start test result container
    # @param [Allure::TestResultContainer] test_result_container
    # @return [Allure::TestResultContainer]
    def start_test_container(test_result_container)
      test_result_container.start = Util.timestamp
      @current_test_result_container = test_result_container
    end

    def update_test_container
      unless @current_test_result_container
        raise Exception.new("Could not update test container, no container is running.")
      end

      yield(@current_test_result_container)
    end

    def stop_test_container
      unless @current_test_result_container
        raise Exception.new("Could not stop test container, no container is running.")
      end

      @current_test_result_container.stop = Util.timestamp
      clear_current_test_container
    end

    # Starts test case
    # @param [Allure::TestResult] test_result
    # @return [Allure::TestResult]
    def start_test_case(test_result)
      unless @current_test_result_container
        raise Exception.new("Could not start test case, test container is not started")
      end

      test_result.start = Util.timestamp
      test_result.stage = Stage::RUNNING
      @current_test_result_container.children.push(test_result.uuid)
      @current_test_case = test_result
    end

    def update_test_case
      raise Exception.new("Could not update test case, no test case running") unless @current_test_case

      yield(@current_test_case)
    end

    def stop_test_case
      raise Exception.new("Could not stop test case, no test case is running") unless @current_test_case

      @current_test_case.stop = Util.timestamp
      @current_test_case.stage = Stage::FINISHED
      clear_current_test_case
    end

    # Starts test step
    # @param [Allure::StepResult] step_result
    # @return [Allure]
    def start_test_step(step_result)
      raise Exception.new("Could not start test step, no test case is running") unless @current_test_case

      step_result.start = Util.timestamp
      step_result.stage = Stage::RUNNING
      @current_test_case.steps.push(step_result)
      @current_test_step = step_result
    end

    def update_test_step
      raise Exception.new("Could not update test step, no step is running") unless @current_test_step

      yield(@current_test_step)
    end

    def stop_test_step
      raise Exception.new("Could not stop test step, no step is running") unless @current_test_step

      @current_test_step.stop = Util.timestamp
      @current_test_step.stage = Stage::FINISHED
      clear_test_step
    end

    private

    def clear_current_test_container
      @current_test_result_container = nil
    end

    def clear_current_test_case
      @current_test_case = nil
    end

    def clear_test_step
      @current_test_step = nil
    end
  end
end
