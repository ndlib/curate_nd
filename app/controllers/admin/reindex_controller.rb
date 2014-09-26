require 'json'

class Admin::ReindexController < ApplicationController
  with_themed_layout('1_column')

  # POST /admin/reindex
  def reindex
    json = JSON.parse(request.body.read)
    puts "got", json
    r = Admin::Reindex.new(json)
    r.add_to_work_queue
    head :ok
  end

end
