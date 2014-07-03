require 'spec_helper'

describe Firebrew do
  it 'should have a version number' do
    Firebrew::VERSION.should_not be_nil
  end
end
