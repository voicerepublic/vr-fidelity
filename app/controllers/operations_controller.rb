class OperationsController < ApplicationController

  # index

  def rp15
    @days, @stages, @sessions = Sync::Rp15.new.sync
  end

end
