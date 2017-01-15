class CommandParser
  def initialize(command)
    @command = command
    @arguments = []
    @options = []
    @options_with_parameter = []
  end

  def argument(name, &block)
    @arguments << Argument.new(name, block)
  end

  def option(short_name, name, description, &block)
    @options << Option.new(short_name, name, description, block)
  end

  def option_with_parameter(short_name, name, description, parameter, &block)
    @options_with_parameter <<
      OptionWithParameter.new(short_name, name, description, parameter, block)
  end

  def parse(command_runner, parameters)
    arguments = parameters.select { |p| !p.start_with? '-' }
    parse_arguments(command_runner, arguments)
    options = parameters - arguments
    parse_options(command_runner, options)
  end

  private
  def parse_arguments(command_runner, arguments)
    arguments.each_with_index do |argument, index|
      @arguments[index].parse(command_runner, argument)
    end
  end

  def parse_options(command_runner, options)
    options.each do |option|
      name, value = split_name_and_value(option)
      if value.to_s == ''
        defined = @options.select { |o| o.name? name }.first
        defined.parse(command_runner) if defined
      else
        defined = @options_with_parameter.select { |o| o.name? name }.first
        defined.parse(command_runner, value) if defined
      end
    end
  end

  def split_name_and_value(option)
    if option.start_with? "--"
      option.split("=")
    else
      [option[0..1], option[2..-1]]
    end
  end
end

class Argument
  def initialize(name, block)
    @name = name
    @block = block
  end

  def parse(command_runner, value)
    @block.call command_runner, value
  end
end

class Option
  def initialize(short_name, name, description, block)
    @short_name = "-#{short_name}"
    @name = "--#{name}"
    @description = description
    @block = block
  end

  def parse(command_runner)
    @block.call command_runner, true
  end

  def name?(name)
    (@name == name) || (@short_name == name)
  end
end

class OptionWithParameter < Option
  def initialize(short_name, name, description, parameter, block)
    super(short_name, name, description, block)
    @parameter = parameter
  end

  def parse(command_runner, value)
    @block.call command_runner, value
  end
end